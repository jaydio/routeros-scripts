# Scripts and Snippets for MikroTik RouterOS

This collection of scripts is meant to make your life easier when installing and maintaining RouterOS deployments. It is based on several best practices as discussed with network engineers, system integrators as well as the community reachable through the [MikroTik Forum](http://forum.mikrotik.com) as well as certified trainers from all around the world.

All scripts should be fairly well documented using inline documentation. Scripts that don't have any documentation go into the raw/ folder.

# Motivation

I needed a place where to stash away scripts and procedures related to RouterOS deployments. A place where I'd be able to share them with the public domain. Majority of scripts found here are related to working on the [Foundation University Network](http://foundationu.com) in [Dumaguete City](http://en.wikipedia.org/wiki/Dumaguete). As of May 10th, 2015 FU is in the process of implementing an MPLS backbone with 30+ routers which includes the following models..

 * [CCR1036-8G-2S+EM](http://routerboard.com/CCR1036-8G-2SplusEM)
 * [CCR1036-12G-4S](http://routerboard.com/CCR1036-12G-4S)
 * [RB2011UiAS-RM](http://routerboard.com/RB2011UiAS-RM)
 * [CRS226-24G-2S+RM](http://routerboard.com/CRS226-24G-2SplusRM)
 * [RB951G-2HnD](http://routerboard.com/RB951G-2HnD)

If you're interested to know more about our setup I suggest you watch my presentation:

* [Campus Backbone using MikroTik's Cloud Core Series](https://www.youtube.com/watch?v=qWTWpUbavuU).

It was held in Manila, December 2014 as part of the first [MikroTik User Meeting in the Philippines](http://mum.mikrotik.com/2014/PH/info).

# Contributions

I'm happy for any kind of contribution including bugfixes, new scripts as well as documentation. However, to allow everyone to benefit from this collection, we should ensure that all scripts are tested and well documented. If you're new to GitHub or git in general [read on](https://guides.github.com/activities/contributing-to-open-source/).

# Directory Structure

Each directory is named after a certain topic and contains a separate README file with detailed instructions on how to get started in using provided scripts.
