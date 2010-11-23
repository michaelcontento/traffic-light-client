Protocol Specification
======================

This is the specification of the lamp-control-procotol used by `Traffic Light Client`_ and the `Traffic Light Server`_.

.. _Traffic Light Client: https://github.com/michaelcontento/traffic-light-client
.. _Traffic Light Server: https://github.com/michaelcontento/traffic-light-server

Overview
--------

The basic workflow is very simple:

1. The client asks the server for the next state
2. The server generates the response
3. The client reads the response and switch into the new state
4. The client remains in the current state for the TTL
5. Goto 1)

Diagramm::

                         CLIENT   *   SERVER
                                  *
                                  *
    START  ---------+             *
       ^            | REQUEST     *
       |            |             *
    TTL DELAY       +----------------> GENERATE
       ^            +----------------- NEXT STATE
       |            |             *
    STATE           | RESPONSE    *      
    CHANGE <--------+             * 
                                  *

Request
-------

The request is just a simple `HTTP-Request`_ to the server. Nothing special or complicated.

.. _HTTP-Request: http://en.wikipedia.org/wiki/Http_request#Request_message

Response
--------

The response is also just a simple `HTTP-Response`_ (`MIME type`_: ``text-plain``) with a human readable text protocol as body. 
The text protocol is a compilation of one or more of the following events.

.. _HTTP-Response: http://en.wikipedia.org/wiki/Hypertext_Transfer_Protocol#Server_response
.. _MIME type: http://en.wikipedia.org/wiki/MIME_type

R-BNF
`````

This document uses a R-BNF notation, which is a mix between `Extended BNF`_ and `PCRE`_-style regular expressions.
R-BNF is fully specified at the `Google Safe Browsing API docs`_ - but here are the important parts for this document:

* Rules are in the form: name = definition. Rule names referenced as-is in the definition. Angle brackets may be used to help facilitate discerning the use of rule names.
* Literals are surrounded by quotation marks: "literal".
* Sequences: (rule1 rule2) or simply rule1 rule2.
* Alternatives groups: (rule1 | rule2).
* Optional groups: [rule[]].
* Repetition: rule* means 0 or more of this rule or this group.
* Repetition: rule+ means 1 or more of this rule or this group.
* CHAR = <any US-ASCII character (octets 0 - 127)>
* LF = <US-ASCII LF, line-feed (10)>
* SP = <US-ASCII SP, space (32)>
* DIGIT = <any US-ASCII digit "0".."9">

.. _Extended BNF: http://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_Form
.. _PCRE: http://en.wikipedia.org/wiki/Perl_Compatible_Regular_Expressions
.. _Google Safe Browsing API docs: http://code.google.com/apis/safebrowsing/developers_guide_v2.html#ProtocolSpecificationRBNF

Event: Lamp
```````````

Specifies the current state for one lamp. Usually the response contains three lamp message (one for each color).

Definition::

    BODY     = "lamp" SP COLOR SP MODE LF
    COLOR    = ("red" | "yellow" | "green" )
    MODE     = ("on" | "off" | "blink" SP INTERVAL)
    INTERVAL = DIGIT+

Example::

    lamp yellow off\n
    lamp red on\n
    lamp green blink 500\n

In this example the red lamp would be on, the yellow lamp off and the green one would blink in an 500ms interval.

**Nerd-Expoit-Prevention**: ``lamp red blink 0`` is treated as ``lamp red off``


Event: Update timer (ttl)
`````````````````````````

Delay in ms for the next request to the server - or "stay in this configuration for XX ms".

Definition::

    BODY = "ttl" SP DIGIT+ LF

Example::
    
    ttl 5000\n

In this case the client would ask the server again after 5000ms.

**Nerd-Expoit-Prevention**: ``ttl 0`` is treated as ``ttl 1000``

Event: Text
```````````

The text that is displayed on the LCD-Display. And the number specifies the length of the message body.

Definition::

    BODY   = "text" SP LENGTH SP [CHAR+] LF
    LENGTH = DIGIT+

Example::
    
    text 11 Hello World\n

    text 12 Hello\n
    World\n

