How to run the tests:
To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup` 
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

We combined phoenix framework with project4.1. First, we started 100 users to construct our network. Each of them makes 10 tweets.

What functionality has been implemented:
1. user sign up/sign in
A new user to the twitter network could use the "sign up" button and create a new username-password pair. Thus, he will become a valid
user. A user who already registered in the twitter network could use the "sign in" button and input his username and corresponding 
password. If the user inputs the wrong password, he cannot log in.
2. subscribe 
The current user could choose to subscribe to other existent users. By clicking on the "new following" button, he could choose the specific
username and follow him.
3. deliver tweets without query to connected users
After a user A subscribes to another user B, whatever user B tweets will be delivered to user A. This is automatic(without query).
4. write tweets
A user could write tweets with or without @ and #. 
For example:
user1 tweets "this is a good day @user2 #DOS". This would be displayed in the webpage.
5. make queries
The current user could query about a given hashtag #. Just input the name of the hashtag(such as DOS), he could get a list of tweets containing
that hashtag.
6. show the mentions
If a user A mentions another user B, the mention will be displayed to B automatically.
7. change passwords
The current user could change his passwords by clicking the "Change Password" button after logging in. He could only change his password. If he tries to change others, the network 
will not allow it.
8. delete accounts
The user could delete his account by clicking "Delete Account". After asking for confirmation, the system will delete his account from the network.

