# WickedMessenger

_DISCLAIMER:  Note this is a work in progress! We're letting it be open on github in hopes that it'll be useful to someone and we'll get some good ideas back. However, all bets are off when it comes to stability of the API and functionality._

## Good Error Messages For Developers

I want to be able to have as many validations in my model as I want.  I want those validations 
to have technical, precise, even pedantic error messages.  This is especially helpful when using 
an XML web service API.  These types of "computer-ish" error messages, however, are not good 
for end-users.

## Bad Error Messages for End-Users

Why are Rails validation errors not good for end-users?  Well, error messages need to be aware 
of the context they're in, use plain English, and suggest a way for the user to repair the 
situation.  Since the model is blissfully unaware of the view the user is looking at way, way up 
in the app stack, how can the model ever hope to fill all those requirements?  It really can't, 
and even if it did, you'd be leaking your view into your model.  This sucks.

## Example

Say you're building a Company object, but one of the fields is an "Administrator Email" that 
will actually create a component User object.  The error messages, if you leave the email 
address blank, would look something like this:

	3 errors prohibited this from being saved
	There were problems with the following fields:

	    * Invitee is invalid
	    * Email can't be blank
	    * Email is too short (minimum is 3 characters)

What does this mean to the user?  Only one of these messages is useful -- "Email can't be blank."  
But it has a problem too.  On the form, the field label is "Administrator Email", so the message 
should be "Administrator email can't be blank".  (This could be very important if you had multiple 
email fields.)

The "Invitee is invalid" is because the Company object has a validates_associated :invitee which 
is actually a User object.  Great for a developer, complete gibberish to an end-user.  Additionally,
of course the "Email is too short", it's freaking *blank*!  Why show that redundant message?

See the NOTES file for more ideas how we would want to convert error messages.

## Dependencies

* ActiveSupport


## License

Copyright (c) 2008 Relevance, Inc.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
