Node.js security token service
===============================================

**Node.js security token service** is a simple security token service (STS) that is used as the authentication provider
for SharePoint 2010. When users log on to the SharePoint site, they are first redirected to the logon page of
the custom STS. They are redirected back to SharePoint after the authentication.

More details here: [http://msdn.microsoft.com/en-us/library/ff955607.aspx](http://msdn.microsoft.com/en-us/library/ff955607.aspx)

The solution is built on top of [Node.js](http://nodejs.org) and [MongoDB](http://www.mongodb.org/). It is not really suitable for production deployments, but it's very helpful during SAML SharePoint tesing.