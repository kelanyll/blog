---
title: "Predicting goals scored with Poisson regression in C++"
date: 2023-07-20T20:13:22+01:00
---

I've been interested in the application of statistical learning to football and how the professionals use it in sports betting. I've also wanted to get some practice in with C++ and this project is the stone killing both birds.

The project is available on GitHub: https://github.com/kelanyll/poisson.

The classic method that beginners are pointed to uses Poisson regression to predict goals scored by both teams in a football match. 

Libraries for this exist out of the box for most languages known for data analysis like Python and R. It was a nightmare to find anything that works out of the box for C++.

You should have a really good reason to use C++ for something like this. And even if you do, you're probably better off using something like [pybind11](https://github.com/pybind/pybind11). If you're committed then I hope this post helps you out.

#### Dependencies
I found the [BOOM](https://github.com/steve-the-bayesian/BOOM) project that has support for Poisson regression. It seems to be intended to be used via an R interface but it's written in C++. It looks to have been used by Google and still maintained which can't hurt. It's built using Bazel so was a pain to integrate with CMake (wrote another [post](https://www.kelanyll.com/posts/cmake-bazel/) about this) but I managed to get it working with [ExternalProject](https://cmake.org/cmake/help/latest/module/ExternalProject.html).

I'm using [DataFrame](https://github.com/hosseinmoein/DataFrame) which is a pandas-like library for manipulating 2D data. 

And I use [GoogleTest](https://github.com/google/googletest) for unit testing.

I'm using the same data (Premier League 11/12) as [opisthokonta](https://opisthokonta.net/?p=276) to help validate the end result. This isn't deterministic as Maximum Likelihood Estimation (MLE) can converge to a local optimum but it's a signal.

> opisthokonta's approach is actually inspired by [this](https://www.math.ntnu.no/emner/TMA4315/2017h/Lee1997.pdf) paper written by Alan J. Lee and not [Maher](http://www.90minut.pl/misc/maher.pdf) which Dixon-Coles builds upon. Something to keep in mind if you start getting confused as to why one implemention 
> sums the parameters and another takes the product of them.

Most of the work here is wrangling the data into a format we can learn a Poisson regression model on. The most significant part is using [one hot encoding](https://en.wikipedia.org/wiki/One-hot) as the variables all need to be numerical.

```c++
void DataFramePosRegTransformerImpl::one_hot_encode_string(ULDataFrame& df) {
    for (std::tuple<ULDataFrame::ColNameType,
                    ULDataFrame::size_type,
                    std::type_index> col_info : df.get_columns_info<std::string>()) {
        auto col_name{std::get<0>(col_info).c_str()};
        std::vector<std::string> col_data{df.get_column<std::string>(col_name)};

        std::unordered_map<std::string, std::vector<unsigned int>> encoded_cols{};

        for (int i = 0; i < col_data.size(); i++) {
            auto encoded_col_name{std::string{col_name} + "_" + col_data[i]};
            if (!encoded_cols.contains(encoded_col_name)) {
                encoded_cols[encoded_col_name] = std::vector<unsigned int>(col_data.size(), 0);
            }
            encoded_cols[encoded_col_name][i] = 1;
        }

        df.remove_column(col_name);

        for (const std::pair<std::string, std::vector<unsigned int>>& pair : encoded_cols) {
            df.load_column<unsigned int>(pair.first.c_str(), std::move(pair.second));
        }
    }
}
```

#### Learning the model

```c++
    ULDataFrame train_df{add_intercept(transform_to_row_per_goals(get_data()))};

    PoissonRegressionTrainer trainer{};

    PoissonRegressionModelData model_data{trainer.get_poisson_regression_model_data(std::move(train_df), "goals")};

    BOOM::PoissonRegressionModel model{static_cast<int>(model_data.x_col_names.size())};
    model.set_data(model_data.data);
    model.mle();
    print_variables(model_data.x_col_names, model.coef().vectorize());

    ULDataFrame test_df{add_intercept(get_test_data())};
    
    for (BOOM::Vector x : trainer.generate_x(std::move(test_df), model_data)) {
        double lambda{exp(model.predict(x))};
        std::cout << "Expected goals: " << lambda << std::endl;
    }
```

In practice, the parameters we learnt are different to opisthokonta:
```
intercept: 0.097209
team_Man United: 0.368457
team_Wolves: -0.384698
team_Swansea: -0.319952
team_Sunderland: -0.302323
team_Blackburn: -0.20577
team_Fulham: -0.232744
team_Wigan: -0.355748
team_Norwich: -0.13755
team_Liverpool: -0.264599
team_Newcastle: -0.0781957
team_Arsenal: 0.199414
team_Bolton: -0.2495
team_QPR: -0.328186
team_West Brom: -0.296448
team_Man City: 0.408514
team_Tottenham: 0.0766307
team_Stoke: -0.519065
team_Chelsea: 0.0662952
team_Aston Villa: -0.491616
team_Everton: -0.20261
opponent_Tottenham: -0.0244485
opponent_Fulham: 0.176567
opponent_Stoke: 0.203365
opponent_Man City: -0.344669
opponent_Wigan: 0.366435
opponent_Chelsea: 0.0899492
opponent_Aston Villa: 0.204339
opponent_Arsenal: 0.162373
opponent_Man United: -0.219121
opponent_Norwich: 0.439115
opponent_Everton: -0.0649364
opponent_Wolves: 0.644837
opponent_Bolton: 0.587764
opponent_Swansea: 0.172638
opponent_Liverpool: -0.0678563
opponent_West Brom: 0.19308
opponent_Sunderland: 0.0702192
opponent_Blackburn: 0.602739
opponent_Newcastle: 0.184476
opponent_QPR: 0.430114
home: 0.268009
```

But when we predict goals scored in an Aston Villa vs Sunderland game, the Poisson $\lambda$ values are the same:
```
Expected goals: 0.94537
Expected goals: 0.999226
```

This suggests that we are still coming to the same optimum. The difference in parameter values could be down to the optimization algorithm being used i.e. Newton-Raphson, IRLS etc.

This is what the probability distribution function looks like for both teams in this game.
![Goals scored](/villa-vs-sun.png#c)


From here you're likely to want to use the Skellam distribution to model the result of the match. But there's still sports bets you can make without that e.g. over/under on goals.

This is likely the simplest approach to predicting goals scored using statistical learning. I'd recommend exploring opisthokonta's material if you're interested in expanding on this.