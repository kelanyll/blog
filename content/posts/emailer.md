---
title: "Building a screenshot emailer service"
date: 2022-08-08T22:49:26+01:00
draft: true
tags: ["system-design", "aws"]
---
Setting up alerts on job listing pages is a useful feature but not all sites provide this functionality. This has previously led me to search for a service that can email you screenshots of a website at a scheduled interval. I have had trouble finding one for free and this got me thinking about how a service like this would work - both imagined on a single machine and also scaled out into a distributed system.

## Single machine
The idea would be that we store a config of "tasks" where one task represents screenshotting a website and emailing it at a specific interval. These are the abstract components that I see representing a system that can run this service at a smaller scale:

###### A scheduler process
This would read the task config on start up and build it into a queue of tasks as well as react upon changes to the task config in order to update the queue. When it's time for a task to be scheduled it could dip into a pool of threads to run that task which would give us the performance benefits of a concurrent system. This is inspired by the cron job scheduler[^1].

###### A web server process
It would implement an API that lets users make changes to the task config - most importantly adding new tasks. An interesting discussion is how a config is represented; I feel a sensible choice would be to store each task config in its own file. This makes it so we don't have to think about concurrency when reading and writing files. The scheduler process can watch a folder for new files in order to trigger adding a new task to the queue. This introduces complexity in that on start up the scheduler process has to read multiple files but we can always merge them if the need arises.

## Distributed system
![A distributed emailer service](/emailer.drawio.png#c)

We can do some cool things with serverless to help this system scale out to serve a larger number of requests.

###### The scheduler
The scheduler itself doesn't need to change too much but now rather than relying on a pool of threads we can use AWS SQS to store tasks that are ready to be run and AWS Lambda for running tasks in a serverless fashion. Using Lambda allows us to run workloads without having to worry about the infrastructure that they run on nor have to pay for idle time on a server when there aren't any screenshots to email[^2]!

###### The data store
Our task config would be stored in a database mostly abstracting away the issue of concurrency. Whether we use a SQL or noSQL database isn't a clear choice - our data model is structured so SQL could make sense but we don't use complex queries so using something like DynamoDB could help us scale out more easily. A sidenote that the process of sharding and scaling out the database in this system would likely take the route of a service like TinyURL[^3]. We don't have to generate a unique key in this case but we'd likely still have to think about using hash-based partitioning to ensure traffic is uniformly distributed (DynamoDB already does this under the hood[^4]).

###### The task config API
We can split our web server process into the API itself and the services that handle requests. We do this by using AWS API Gateway as the front door to adding and removing tasks in the system where Lambda is triggered to handle each request. This again gives us the benefits of serverless over running a web server. 

How does our scheduler know when a new task has been added to the database? We could have it regularly poll the database but this wouldn't be very efficient. We could also use a push mechanism where the database somehow notifies the scheduler that a changes has been made. PostgreSQL has a feature that allows it to send notifications to clients who are explicitly "listening" to changes to the database[^5]. I couldn't find something similar for DynamoDB but the way I see this working is either by publishing to an SQS from a DynamoDB stream using Lambda or having the Lambda that writes to the database publish the new task directly to SQS. The scheduler would then consume from SQS, dynamically adding new tasks to its queue.

I will hopefully revisit this at some point with the aim of building it out but this was a quick look at how a service like this could be architected. Would you do anything differently? Let me know what you think of the design choices here!

[^1]: https://en.wikipedia.org/wiki/Cron#Multi-user_capability
[^2]: https://www.nakivo.com/blog/aws-lambda-vs-amazon-ec2-which-one-to-choose/
[^3]: https://www.educative.io/blog/system-design-tinyurl-instagram
[^4]: https://docs.aws.amazon.com/amazondynamodb/latest/developerguide/HowItWorks.CoreComponents.html
[^5]: https://www.postgresql.org/docs/current/sql-notify.html