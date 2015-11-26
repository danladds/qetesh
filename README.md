Qetesh is a framework for creating ultra-fast web applications using the Vala programming language on the server side and Javascript on the client side. This repository is for the main shared module, client side code, and micro web server.

Qetesh is focussed on web applications, rather than web sites, although there is no reason that it cannot be used to add functionality on top of a site developed primarily in other technologies. It hopes to facilitate rapid development alongside high performance. The Javascript frontend can be tied into other frameworks or used as a standalone.

The server also provides a RESTFUL API as the basis of its communication with the frontend, which can be used additionally as a user API. It is possible to run the server without the frontend entirely, in which case it forms a lightweight web service server for Vala services.

Here is a very basic overview of how Qetesh works:

- The view layer consists of HTML templates. These are served by a regular web server, such as Apache. As Qetesh interacts with these templates within the user's browser, developers are free to use other technologies, like scripting languages, to transform templates before they are processed by Qetesh.

- The view is controlled by client-side Javascript which can access data objects and their functions transparently as defined on the server, subject to acccess controls set on the server side.
 
- The server provides a JSON API, although this is abstracted on the front end to provide an object-based interface. It is recommended to proxy this, through either the template web server, or a separate regular web server. The API layer can also be used as a standalone.

- Client-side data objects can be bound to to HTML templates in two directions, with control over when changes are pushed or pulled from the server.
 
- Application modules are built against the same shared library as the server, which provides the Qetesh programming framework. The application's core object registers data points, which act as controllers for a URL pathway. Data points can make use of the ORM layer to speed up database access development. Database connectors are pluggable: MySQL is currently provided; I hope to add PGSQL at the least; and application developers are free to add their own connectors.

 Immediate plans -> Pipe dreams:
-Finishing everything that's half-done!
-Documentation!
-Binaries & packaging
-A system for debugging
-An app packaging and deployments system - on top of automake
-A sandbox testbed /  dev environment
-IDE plugin - possibly for Geany, as it's very lightweight - integrating the former
 
Advantages of Qetesh:

- Compatible with other technologies
- Templates are designer-friendly and based on Angular.JS, meaning easy editing by designers and frontend developers not familiar with Vala
- Vala language easily learned by Java or .NET programmers
- Concise, simple API enabling rapid development
- Applications are easily ported, with either Vala itself or Qetesh providing abstraction
- ORM and data binding stack cut out many lines of boilerplate code, and provide a consistent interface and nomenclature across client and server sides.
- Easy to use only parts of the Qetesh system if desired!
- "Convention over configuation" architecture
- Fine-grained caching control - decide what gets refetched and rerun and when 
