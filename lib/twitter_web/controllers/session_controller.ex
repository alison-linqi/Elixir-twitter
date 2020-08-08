defmodule TwitterWeb.SessionController do
  use TwitterWeb, :controller
  alias Twitter.Data.User
  alias Twitter.Data
  alias Twitter.Repo
  alias Twitter.Data.Follow
  alias Twitter.Data.Tweet
  alias Twitter.Data.Retweet
  alias Twitter.Data.Hashtag
  alias Twitter.Engine, as: Engine
  alias Twitter.Client

  def new(conn, _) do
    render(conn, "new.html")
  end

  def following(conn, %{"id" => uid}) do
    changeset = Follow.changeset(%Follow{}, %{uid: uid})
    render(conn, "following.html", changeset: changeset)
  end
  
  def newfollowing(conn, %{"follow" => follow_params}) do
    %{"following" => following, "userid" => userid} = follow_params
    user = Data.get_userid!(userid)
    uid = user.id
    IO.puts "@@ #{inspect userid} #{inspect following} #{inspect uid}"
    Client.new_subscribe(userid, following)
    conn |> redirect(to: Routes.signin_path(conn, :homepage, uid))
  end

  def writetweet(conn, %{"id" => id}) do
  	changeset = Tweet.changeset(%Tweet{}, %{})
    render(conn, "writetweet.html", changeset: changeset)
  end

  def sendtweet(conn, %{"tweet" => tweet_params}) do
    %{"content" => content, "userid" => userid} = tweet_params
    IO.puts "@@ #{inspect userid} #{inspect content}"
    user = Data.get_userid!(userid)
    uid = user.id
    IO.puts "@@ #{inspect userid} #{inspect content} #{inspect uid}"
    Client.send_tweet(userid, content)
    conn |> redirect(to: Routes.signin_path(conn, :homepage, uid))
  end

  def retweet(conn, _) do
    changeset = Retweet.changeset(%Retweet{}, %{})
    render(conn, "retweet.html", changeset: changeset)
  end

  def sendretweet(conn, %{"retweet" => retweet_params}) do
    %{"content" => content, "user" => userid, "original" => original} = retweet_params
    IO.puts "@@ #{inspect original} #{inspect userid} #{inspect content}"
    user = Data.get_userid!(userid)
    uid = user.id
    Client.retweet(userid, original, content)
    conn |> redirect(to: Routes.signin_path(conn, :homepage, uid))
  end

  def hashtag(conn, _) do
    changeset = Hashtag.changeset(%Hashtag{}, %{})
    render(conn, "hashtag.html", changeset: changeset)
  end
  
  def hashtagresult(conn, %{"hashtag" => hashtag}) do
    %{"htname" => htname} = hashtag
    IO.puts "@@ #{inspect htname}"
    render(conn, "hashtagresult.html", htname: htname)
  end
end
