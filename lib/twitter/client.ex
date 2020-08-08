defmodule Twitter.Client do 
  use GenServer
  
  ##################### client side ########################
  # initial values 
  # 0:nickname(String), 1:password
  def start_link(nickname, password) do 
    #nodeid = Base.encode16(:crypto.hash(:sha, Integer.to_string(nodenum)))
    #IO.puts "#{inspect nickname} #{nickname}"
    name = String.to_atom(nickname)
    if Enum.find(Twitter.Engine.get_userlist(), fn x -> x == name end) do
      #IO.puts "This user is already existed."
      nil
    else
      GenServer.start_link(__MODULE__,[nickname, password], name: name)
      Twitter.Engine.init_client(name)
      #IO.puts "    #{nickname} has been created."
      Twitter.Engine.get_userlist
    end
    
    #IO.puts "start_link finished"
  end

  #nickname_self(atom)
  def get_nickname(nickname_self) do
    GenServer.call(nickname_self, :get_nickname)
  end

  #nickname_self(atom)
  def get_subscribe_list(nickname_self) do
    sublist = Twitter.Engine.get_sublist()
    Enum.find(sublist, fn y -> Enum.at(y, 0) == nickname_self end)
  end

  #nickname_self(atom)
  def stop_self(nickname_self) do
    GenServer.stop(nickname_self, :normal)
  end

  #nickname_self(String)
  def query_subscribe_tweets(nickname_self) do
    if Enum.find(Twitter.Engine.get_userlist(), fn x -> x == String.to_atom(nickname_self) end) do
      GenServer.call(:engine, {:query_subscribe_tweets, nickname_self})
    else
      IO.puts "Not existed."
    end
  end

  #nickname_self(String)
  def query_my_tweets(nickname_self) do
    if Enum.find(Twitter.Engine.get_userlist(), fn x -> x == String.to_atom(nickname_self) end) do
      GenServer.call(:engine, {:query_my_tweets, nickname_self})
    else
      IO.puts "Not existed."
    end
  end

  #hashtag(String)
  def query_hashtag(hashtag) do
    GenServer.call(:engine, {:query_hashtag, hashtag})
  end

  #nickname_self(String)
  def query_at_me(nickname_self) do
    if Enum.find(Twitter.Engine.get_userlist(), fn x -> x == String.to_atom(nickname_self) end) do
      GenServer.call(:engine, {:query_mention_me, nickname_self})
    else
      IO.puts "Not existed."
      nil
    end
  end



  #nickname_self(String), nickname_sub(String)
  def new_subscribe(nickname_self, nickname_sub) do
  	userlist = Twitter.Engine.get_userlist()
  	if Enum.find(userlist, fn x -> x == String.to_atom(nickname_sub) end) && nickname_self != nickname_sub do
  		GenServer.cast(:engine, {:new_subscribe, nickname_self, nickname_sub})
  	else
  		IO.puts "You can't subscribe this user (not existed or self)."
  	end
  	
    Twitter.Engine.get_sublist()
  end

  #nickname(String), tweet_content(String)
  def send_tweet(nickname, tweet_content) do
  	s = String.codepoints(tweet_content)
  	t2 = if (Enum.find(s, fn x -> x=="@" end)) do
  		index = Enum.find_index(s, fn x -> x=="@" end)
  		{_,t2}=Enum.split(s,index)
  		index = if Enum.find_index(t2, fn x -> x==" " end) do
  			Enum.find_index(t2, fn x -> x==" " end)
  			else
  				0
  		end
  		{t2,_}=Enum.split(t2,index)
  		t2
  	else
  		nil
  	end
  	mention = if t2 != nil && t2 != [] do
  		Enum.join(tl(t2))
  	else
  		nil
  	end
  	
  	t2 = if (Enum.find(s, fn x -> x=="#" end)) do
  		index = Enum.find_index(s, fn x -> x=="#" end)
  		{_,t2}=Enum.split(s,index)
  		index = if Enum.find_index(t2, fn x -> x==" " end) do
  			Enum.find_index(t2, fn x -> x==" " end)
  			else
  				0
  		end
  		{t2,_}=Enum.split(t2,index)
  		t2
  	else
  		nil
  	end
  	hashtag = if t2 != nil && t2 != [] do
  		Enum.join(tl(t2))
  	else
  		nil
  	end

    GenServer.cast(:engine, {:send_tweet, nickname, mention, hashtag, tweet_content})
    if mention != nil do
  		mention = String.to_atom(mention)
  		IO.puts "new mention for #{inspect mention}"
  		GenServer.cast(mention, {:new_mention, nickname, tweet_content})
  	end
    Twitter.Engine.get_all_tweets()
  end

  def retweet(nickname, author, tweet_content) do
  	tweet_content = "//@" <> author <> ": " <> tweet_content
  	GenServer.cast(:engine, {:retweet, nickname, tweet_content})
  	Twitter.Engine.get_all_tweets()
  end


  ################### server side ##########################
  def init(metadata) do 
    {:ok, metadata}
  end

  def handle_call(:get_nickname, _from, metadata) do
  	nickname = Enum.at(metadata,0)
    {:reply,nickname,metadata}
  end

  def handle_call(:get_subscribe_list, _from, metadata) do
    subscribe = Enum.at(metadata,1)
    #IO.puts "#{inspect neighbors}"
    {:reply,subscribe,metadata}
  end

  def handle_cast({:new_mention, writername, tweet_content}, metadata) do
  	IO.puts "#{writername} mentioned you: #{tweet_content}"
  	{:noreply, metadata}
  end

  def terminate(:normal, state) do
  	IO.puts "#{inspect self()} normal"
  end
   
end