---
title: "An API for Fantasy Premier League: FPLWrapper"
date: 2021-01-14T19:44:06Z
draft: false
tags: ["fpl", "api", "java"]
---
Some of us who play Fantasy Premier League (FPL) often rely on data analytics to make decisions about our squad. However, FPL doesn't provide a public API with which to pull down data. FPLWrapper is an API that allows you to fetch FPL data easily for use in your own analysis. It abstracts away the endpoints exposed by FPL to provide an interface that allows you to get the information you need with only one request.

FPLWrapper started off as a toy project to learn the Dropwizard server framework. It makes use of PostgreSQL, a relational database, to persist data. It uses Java concurrency to take advantage of multi-thread parallelism when writing to the database. The Java server and database are containerised using Docker and deployed via AWS on an EC2 instance (thanks Free Tier!). See the GitHub repo for more information: https://github.com/kelanyll/FPLWrapper.

If you'd like to dive right in then have a look at the Swagger documentation: http://kelanyll.com/fpl-wrapper/swagger. I'm going to go through the current endpoints available and give examples of what you can do with them using Python 3, one of the most popular programming languages for data analysts. The examples are in the GitHub repo if you'd like to jump straight into the code: https://github.com/kelanyll/FPLWrapper/tree/master/examples.

## /player

The player endpoint allows you to get statistics of a player by name. This includes all the statistics available on the FPL website for this season and summary statistics for previous seasons played in the Premier League.

The simplest thing you can do is compare the statistics of two different players. As a Chelsea fan, I'm particularly interested in how Reece James stacks up against one of the best right-backs in the Premier League right now, Trent Alexander-Arnold. To do this I'm going to use the statistics that go into creating a player's ICT index: Influence, Creativity and Threat - see this link for more information: https://www.premierleague.com/news/65567.

In the following code snippet, I'm using the [Requests](https://requests.readthedocs.io/en/master/) library to hit the player endpoint once for each player. I'm sending a `GET` request with the player's name as a `name` query parameter.  I calculate this season's averages for those stats and then I plot this in a radar chart using [Matplotlib](https://matplotlib.org/).

```python
r1 = requests.get("http://www.kelanyll.com/fpl-wrapper/player?name=Reece%20James")
r2 = requests.get("http://www.kelanyll.com/fpl-wrapper/player?name=Trent%20Alexander-Arnold")
jamesStats = r1.json()
trentStats = r2.json()

stats = ['Influence', 'Creativity', 'Threat']
lowerStats = list(map(lambda x: x.lower(), stats))
jamesAverageStats = getAverageStats(lowerStats, jamesStats['history'])
trentAverageStats = getAverageStats(lowerStats, trentStats['history'])

theta = radar_chart.radar_factory(3)
fig, ax = plt.subplots(figsize=(5,6), subplot_kw=dict(projection='radar'))
ax.set_varlabels(stats, position=[0, 0.1])
ax.set_rlabel_position(60)
ax.set_title("Reece James vs Trent Alexander-Arnold ICT", weight='bold', size='large', position=(0.5, 1.15),
             horizontalalignment='center')
ax.plot(theta, jamesAverageStats, label="Reece James", color="blue")
ax.fill(theta, jamesAverageStats, facecolor="blue", alpha=0.25)
ax.plot(theta, trentAverageStats, label="Trent Alexander-Arnold", color="red")
ax.fill(theta, trentAverageStats, facecolor="red", alpha=0.25)
ax.legend(loc=(0.7, 1), fontsize="x-small")
plt.show()
```

![Reece James vs Trent Alexander-Arnold ICT](/post-fpl-wrapper-radar.png#c)

We can see that this season James has been seriously competing with Trent. Those that don't have the cash to bring in Trent should really consider Reece James who is more than £2m cheaper at £5.2m.

## /my-team

The my-team endpoint allows you to get your current team and various relevant information about each player such as their next fixture.

Using this endpoint in conjunction with the player endpoint you can graph how your current players have performed over the season in comparison with each other. I'm going to graph my players' points per game per value (PPGPV) to see if they've lived up to their price tags and include Reece James to see how he matches up against my defenders.

In this code snippet, I send a `POST` request to the my-team endpoint with my email and password in the data payload. I then hit the player endpoint, as I did in the first example, for each player in my team (this is abstracted away in the `getPlayer` function). I calculate PPGPV for each player and then plot it in a bar chart.

```python
class Player:
    def __init__(self, player):
        self.player = player
        self.ppgpv = calculatePPGPV(player)

    def getPpgpv(self):
        return self.ppgpv

r = requests.post("http://www.kelanyll.com/fpl-wrapper/my-team", data ={'email': 'yll.kelani@hotmail.co.uk',
                                                                        'password': 'insert-password'});
team = r.json()

players = list(map(lambda x: Player(getPlayer(x["name"])), team))
players.append(Player(getPlayer("Reece James")))
players.sort(key=lambda x: x.ppgpv)

fig, ax = plt.subplots(figsize=(6,6))
ax.set_ylabel("Points per game per value")
playersIndices = range(0, len(players))
bars = plt.bar(playersIndices, list(map(lambda x: x.ppgpv, players)))
jamesIndex = next(i for i,x in enumerate(players) if x.player['name'] == "Reece James")
bars[jamesIndex].set_color('green')
plt.xticks(playersIndices, list(map(lambda x: x.player['name'], players)), rotation="vertical")
plt.gcf().subplots_adjust(bottom=0.32)
plt.show()
```

![My team's PPGPV](/post-fpl-wrapper-bar.png#c)

It's clear from the PPGPV stats that McCarthy at £4.7m has been quite a bargain. Reece James ranks high at fourth best amongst my team and would definitely be an improvement over some of my defenders such as George Baldock who is in the same price band at £5m.

I hope this has been a helpful introduction to FPLWrapper. If you have any feedback, please feel free to shoot me an email!
