# Angular Route Reuse Strategy

## Introduction

Businesses often push out an application performance into the background, and the speed of delivering a functionality to a market becomes on focus. Meanwhile, the response time of an application has a big impact on its UX. The scheme is simple: the faster the application responses, the more comfortable it is to use, and the higher the customer loyalty your product gets.

One day, a colleague and I were looking for a way to speed up the navigation time of our application written in Angular, without having to refactor existed code. We had an application that needed to be addedd support for a tabs. It was an accounting apps.

I wanted to open each page via a direct link and have the navigation remain in the browser history. Our pages were heavy and we didn’t want to load them all over and over again, thus we needed all the components to be cached and capable to save it's state.

Something like this:

(change picture)

![Untitled](/assets/images/angular-route-reuse/1.png)

The solution required a little research, but I learned some interesting things about how routing works in Angular.

## What is Route Reuse Strategy?

Every time we navigate through an application, Angular creates and destroys components that reside on our pages. This is a difficult process that consumes a lot of time.

Luckily, Angular gives us a tool to manage the loading and unloading of components - the RouteReuseStrategy interface. Unfortunately, it is not very clearly documented. Here's the description:

[https://angular.io/api/router/BaseRouteReuseStrategy](https://angular.io/api/router/RouteReuseStrategy)

[https://angular.io/api/router/RouteReuseStrategy](https://angular.io/api/router/RouteReuseStrategy)

## **Stage 1 - Path Construction**

(See the file [https://github.com/angular/angular/blob/master/packages/router/src/create_router_state.ts](https://github.com/angular/angular/blob/master/packages/router /src/create_router_state.ts))

The first thing the router tries to do is build a path tree. For us, it all starts with the *shouldReuseRoute* method. This method answers the question “Should I use the saved *ActivatedRoute*?” The input receives two parameters: the current *ActivatedRouteSnapshot* and the future *ActivatedRouteSnapshot* for the same nesting depth.

1. If ***shouldReuseRoute*** returns false, then the router attempts to retrieve the already saved state by calling the *retrieve* method, but uses the returned ***DetachedRouteHandle*** only to construct the ***ActivatedRoute*** (NOT uses the stored component). If instead of handle we received null, then a new *ActivatedRoute* will be created.
2. If ***shouldReuseRoute*** returns true, then the ***ActivatedRoute*** of the previous path is used. Then ***shouldReuseRoute*** is called recursively on the child nodes of the route.

The output is a tree Url and the router moves to the route activation stage.

An example of a path tree. Each node represents some part of the URL. I circled the old path (*from which we are moving,* path1) with a red frame, and the new one (*to which we are moving*, path2) with a blue frame.

![test](/assets/images/angular-route-reuse/2.png)

 
**Step 2 – Deactivate the old route**

([source](https://github.com/angular/angular/blob/master/packages/router/src/create_router_state.ts)) At the second stage, the router must deactivate the old paths; the following RouteReuseStrategy methods are called for the path tree:

• **shouldDetach** and **store**

• **shouldDetach** and **retrieve**

**ShouldDetach** is called for the old path. The traversal of the tree begins from the part where the differences between the branches are first encountered (in the picture this is the node with path = "path1").

This method should decide whether the path needs to be saved for reuse in the future.

1. If **shouldDetach** returns true, then the entire child tree will be saved by calling the **store** method. Traversal of the tree stops
2. If **shouldDetach** returns false, then the child nodes will be checked recursively. For them, **shouldDetach** is also called

At the output we receive the current DetachedRouteHandle saved in our strategy, the router-outlet is disconnected

## **New route activation stage**

**shouldAttach** must decide whether the strategy is able to return the handle of the component previously saved to the router. The tree traversal starts from the part where the differences occur (path: ":id" on path2).

1. If **shouldAttach** returns true, then the retrieve method is called, which should return the handle for the saved component. Then store is called with the parameter handle = null to null the stored handle.
2. If **shouldAttach** returns false or retrieve returns null, then the component will be created again. At the output, we get a ready-made tree with created components and linked to router outlets.