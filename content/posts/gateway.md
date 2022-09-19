---
title: "From a single machine to an encapsulated cloud architecture"
date: 2022-09-18T00:00:00+01:00
draft: true
tags: ["system-design", "aws"]
---
Until now this blog and the FPLWrapper service had been hosted on the same EC2 instance. This included Nginx to sit in front of them as a proxy:

![Old design](/blog-original.drawio.png#c)

This obviously wasn't scalable and could end up being a real pain to redeploy whenever I made any changes. On the other hand, using a more extensive set of AWS services enables me to scale out simpler, automate some operational tasks and only pay for the compute power I use. This is what that looks like in practice:

![New design](/blog-new.drawio.png#c)

###### Amplify
The first step was to figure out what I could use to replace Nginx and I needed to find something that could ideally do two things:
1. Serve up the static files making up my blog.
2. Redirect requests for a specific path (/fpl-wrapper) to the Dropwizard server running on my EC2 instance.

I originally thought to host my blog in an S3 bucket but came upon AWS Amplify[^1] which seemed to fill both criteria and was quite easy to set up. An added benefit which I hadn't considered was the ability of Amplify to rebuild the site on a new commit to a specified branch in Git - something I couldn't get with S3 alone.

One hurdle was that Amplify can only redirect requests over HTTPS and the FPLWrapper API is only served over HTTP. I considered enabling HTTPS on the Dropwizard server which would have involved generating and signing a TLS certificate but, luckily, I came to my senses. If I went this route then any service that I spin up and redirect to via Amplify would have to have TLS configured individually. It makes more sense to configure TLS once via a proxy that sits in front of all services rather than do the work for each individual one.

###### API Gateway
Amplify is valuable enough to incorporate despite the redirect functionality not suiting my use case but AWS API Gateway more naturally fits the role of a proxy. It's a very useful product which lets you freely configure endpoints to point to other AWS services or even a generic URL. It can also route requests downstream via HTTP so I went ahead and set up a route to point to the FPLWrapper service as well as a default route to direct requests to Amplify.

> **What is the difference between a Route and a Stage?**\
> This was something that confused me at first as on creation of my API with API Gateway, I had an instance of each named "$default". A route directs requests by their path and HTTP method. A stage represents a unique deployment of your API and would, most likely, be used to facilitate multiple environments e.g. dev, prod.

I'm using the HTTP API service rather than the REST API service (which is more feature-rich) purely as a cost-saving measure. This means that there is no abstraction for routing to an EC2 instance - I have to explicitly provide the URL.

I couldn't forget about configuring HTTPS altogether however as I had to make sure that the TLS certificate that API Gateway provides included my domain: "www.kelanyll.com". For this I used AWS Certificate Manager (ACM) to issue a TLS certificate which was very easy and also free!

A potential drawback of this is that you can't export certificates generated using ACM. This is a good example of the *stickiness* of AWS and is definitely worth thinking about. I'm fine with this as I don't foresee a need to leave the AWS ecosystem any time soon.

The last piece of the puzzle was to add my domain as a "custom domain" which includes selecting the TLS certificate stored with ACM. I couldn't find much documentation on what this does under the hood but I imagine the main reasons are to configure TLS correctly and whitelist requests coming from that domain so you don't run into CORS issues.

###### Route 53
My existing DNS provider was GoDaddy and to point my domain to API Gateway I only had to add a CNAME record mapping "www.kelanyll.com" to the given URL. For the benefit of user experience, I also wanted to map "kelanyll.com" to "www.kelanyll.com" but this proved a bit more difficult as GoDaddy wouldn't let me set up a CNAME record for the root domain[^2]. It does offer a service for redirecting URLs with a 301 response but I couldn't quite get this to work. It began to make more sense to port my domain over to a provider with a broader set of features. 

AWS Route 53 seemed like a good choice due to a breadth of functionality and easy integration with AWS services. Another example of AWS' stickiness is the Route 53 pricing model which incurs no charge for queries forwarded to other AWS services including API Gateway. 

An interesting thing I learned as part of this is that you can register a domain with a provider but have a different provider carry out DNS management. This meant I could keep my domain registered under GoDaddy but configure DNS records with Route 53 at very little extra cost (a flat monthly cost for owning a "hosted zone"). Using Route 53, I was able to create A records to point "www.kelanyll.com" to the API Gateway URL and "kelanyll.com" to "www.kelanyll.com". Conventionally, A records point at IP addresses and I imagine this is what Route 53 does under the hood by sourcing the IP addresses of the AWS services that I select - a very useful abstraction!

###### EC2
Since the FPLWrapper service is served using Dropwizard, it made sense to continue to host this with AWS EC2. One problem with this is that EC2 instances have dynamic IP addresses by default so they may change on a reboot. It doesn't make sense to reconfigure API Gateway every time it changes so to solve this I created an Elastic IP address which is a static IP address and associated it with the EC2 instance.

An interesting aside is that the first Elastic IP address I generated was blacklisted by Fantasy Premier League. I solved this simply by generating a new one but I have also reduced the frequency of my requests to their servers to ensure I'm not overusing them.

A big change I've made to the configuration of this instance is setting up the user data to run the FPLWrapper service on a reboot[^3].

This is a huge quality of life change.

The ability to just reboot the instance without SSHing in is so nice - automating things always seems to be worth the effort.

###### CloudFront
In short, I'm using CloudFront to redirect requests made via HTTP to HTTPS so they make it to API Gateway. 

Another decision made from a UX perspective. 

It's quite hacky to use a CDN for this purpose and I'm surprised that nothing else really exists to solve this problem. But, it was fairly easy to configure and as long as it's cost-effective I'm happy with it.

Rebuilding this infrastructure has made it 10x easier to maintain and should hopefully help me scale out easier as it grows. One thing to look at in the future is integrating monitoring and logs and it will be interesting to look into what AWS offers here. Hope this is helpful to anyone starting off with AWS and please let me know if there's any other handy services I could have used to improve this system!

[^1]: https://aws.amazon.com/blogs/architecture/serving-content-using-fully-managed-reverse-proxy-architecture/
[^2]: https://serverfault.com/questions/408017/why-does-heroku-warn-against-naked-domain-names
[^3]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html
