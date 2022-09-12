---
title: "My soldering debut"
date: 2022-09-09T18:24:13+01:00
tags: ["soldering", "electronics"]
---
A couple months ago, I stumbled upon a YouTuber called StezStix Fix? who mainly posts videos of himself fixing old games consoles. As someone who would break apart electronics when I was younger but never went near a soldering iron, I was fascinated by how fun and simple he made it seem. 

In an effort to get in on the fun I bought a faulty Playstation 5 controller on Ebay but I'm still working up to that. Here I'm going to show you how I got on with my first attempt at soldering on a practice board that flashes pretty lights!

[This](https://www.amazon.co.uk/gp/product/B075SWVZNJ/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1) is the board and [this](https://www.amazon.co.uk/gp/product/B07SLRRYMC/ref=ppx_yo_dt_b_search_asin_title?ie=UTF8&psc=1) is the kit I used although the basic tools I needed for this board were:
- Soldering iron (and stand)
- Solder (with flux)
- Desoldering pump
- Wire cutters
- Tweezers

![My workspace](/soldering/workspace.jpg#c)

I started off by adding the resistors but do you notice anything strange about them? Some of them are the wrong way around! Kind of glad I made this mistake early so I could get some practice in removing components as well as soldering them on.

![Resistors](/soldering/resistors.jpeg#c)

Using my desoldering pump and quite a bit of diligence, I managed to correct the resistors. One tip for readers is that once you've sucked up the solder with the pump, often the wire remains stuck to the pad so you'll need to give the component a pull while the soldering iron is on the pad. This is where some helping hands[^1] would have come in handy but I had to make do.

![Resistors corrected](/soldering/resistors-fixed.jpg#c)

Next step was to add the LEDs. The tough part here was to make sure I didn't bridge the connections between components as the pads were very close together. To speed things up I put multiple LEDs on the board at once for soldering, so I couldn't bend the wires to lock them in place. Although the LEDs started off pretty wonky, I eventually discovered tape which helped keep them in place while I soldered.

![LEDs](/soldering/leds.jpg#c) ![LEDs back](/soldering/leds-back.jpg#c)

Below is a video of me soldering the last component onto the board (the battery holder). Please excuse the residue on the board; my 99% isopropyl alcohol wasn't very 99% and I didn't have much to clean it up with. Here's a couple things I learned with my first attempt at soldering:
- Use some tape to hold down components while you solder
- Heat the pad with the soldering iron (not the solder directly) so that the melted solder more easily joins the pad
- Don't block the hole with the iron so that the melted solder can fall into it and make a strong bond with the pad on the other side of the board - look at the bumps on the other side of the board in the video

{{< youtube 5QsL-hpYT8M >}}
\
The all-important question now - did it work?

{{< youtube RY1FqC-6-QA >}}
\
Yes! To be honest, I wasn't confident that it _would_ work, as I wasn't sure the connections I made right at the start were strong enough and thought maybe the residue on the board could interfere. But it did and now I don't have to buy a multimeter (yet). Now onto that PS5 controller..

[^1]: https://www.amazon.co.uk/QuadHands-Helping-Hands-Third-Soldering/dp/B00GIKVP5K