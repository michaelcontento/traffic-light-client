Protocol Specification
======================

R-BNF
-----

This document uses a R-BNF notation, which is a mix between Extended BNF and PCRE-style regular expressions.
Fully specified at the `Google Safe Browsing API docs`_ but here are the parts that are important for document:

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

.. _Google Safe Browsing API docs: http://code.google.com/apis/safebrowsing/developers_guide_v2.html#ProtocolSpecificationRBNF

Message: Lamp
-------------

Specifies the state of one lamp and the *TIMER-MS* is the blink interval in milliseconds.

Definition::

    BODY     = "lamp" SP COLOR SP MODE LF
    COLOR    = ("red" | "yellow" | "green" )
    MODE     = ("on" | "off" | "blink" SP TIMER-MS)
    TIMER-MS = DIGIT+

Example::

    lamp yellow off\n
    lamp red on\n
    lamp green blink 500\n

In this example the red lamp would be on, the yellow lamp off and the green one would blink in an 500ms interval.


Message: Update timer (ttl)
---------------------------

Delay in ms for the next request to the server.
    

Definition::

    BODY = "ttl" SP DIGIT+ LF

Example::
    
    ttl 5000\n

In this case the client would ask the server again after 5000ms.

Message: Text
-------------

The text that is displayed on the LCD-Display. 

Definition::

    BODY = "text" SP DIGIT+ SP [CHAR+] LF

Example::
    
    text 11 Hello World\n

    text 12 Hello\n
    World\n
