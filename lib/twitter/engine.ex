defmodule Twitter.Engine do 
  use GenServer
  
  ##################### client side ########################
  # initial values 
  # 0:nickname, 1:subscribe tuple, 
  def start_link() do 
  	#0: user list
    #1: users and their tweets [[:user1,[#,@,""],[#,@,""]],[:user2,[#,@,""],[#,@,""]]]
    #2: users and their subscribe
    GenServer.start_link(__MODULE__,[[],[],[]], name: :engine)
    IO.puts "*** Twitter Engine started."
  end

#sign up(String)
  def sign_up(new_name, password) do
    #if Enum.find(get_userlist(), fn x -> String.to_atom(x) == new_name end) do
    #  IO.puts "This user is already existed."
    #else
      Twitter.Client.start_link(new_name, password)
    #end
  	
    #GenServer.cast(:engine, {:sign_up, new_name})
    #get_userlist()
  end

#delete acount: delete tweets, delete from subscribe list
  def delete_account(account) do
    if Enum.find(get_userlist(), fn x -> x == String.to_atom(account) end) do
      GenServer.cast(:engine, {:delete_account, account})
      get_userlist()
      get_all_tweets()
      get_sublist()
      Twitter.Client.stop_self(String.to_atom(account))
    else
      IO.puts "Not existed."
      nil
    end
  end

  def get_userlist() do
    GenServer.call(:engine, :get_userlist)
  end

  def get_all_tweets() do
    GenServer.call(:engine, :get_all_tweets)
  end

  def get_sublist() do
    GenServer.call(:engine, :get_sublist)
  end

  def init_client(client_name) do
    GenServer.cast(:engine, {:init_client, client_name})
    get_all_tweets()
    get_sublist()
  end


  ################### server side ##########################
  def init(metadata) do 
    {:ok, metadata}
  end

  def handle_cast({:init_client, client_name}, metadata) do
    metadata = [Enum.at(metadata,0) ++ [client_name], Enum.at(metadata,1) ++ [[client_name]], Enum.at(metadata,2) ++ [[client_name]]]
    {:noreply, metadata}  
  end

  def handle_call(:get_userlist, _from, metadata) do
    users = Enum.at(metadata,0)
    {:reply,users,metadata}
  end

  def handle_call(:get_all_tweets, _from, metadata) do
    tweets = Enum.at(metadata,1)
    {:reply,tweets,metadata}
  end

  def handle_call(:get_sublist, _from, metadata) do
    sublist = Enum.at(metadata,2)
    {:reply,sublist,metadata}
  end

  def handle_call({:query_subscribe_tweets, nickname_self}, _from, metadata) do
  	nickname_self = String.to_atom(nickname_self)
    sublist = Enum.find(Enum.at(metadata,2), fn x -> List.first(x) == nickname_self end)
    sublist = List.delete_at(sublist,0)
    tweets_list = Enum.at(metadata,1)
    tweets = Enum.map(sublist, fn x -> Enum.find(tweets_list, fn y -> Enum.at(y, 0) == x end) end)
    
    {:reply,tweets,metadata}
  end

  def handle_call({:query_my_tweets, nickname_self}, _from, metadata) do
    nickname_self = String.to_atom(nickname_self)
    tweets_list = Enum.at(metadata,1)
    tweets = Enum.find(tweets_list, fn y -> Enum.at(y, 0) == nickname_self end)
    
    {:reply,tweets,metadata}
  end

  def handle_call({:query_hashtag, hashtag}, _from, metadata) do
    tweets_list = Enum.at(metadata,1)
    tweets = Enum.map(tweets_list, fn x ->  writer = hd(x)
    										x = List.delete_at(x,0)
    										find_all_hashtag(x, [], writer, hashtag) end)
    tweets = delete_nil(tweets)
    {:reply,tweets,metadata}
  end
  def find_all_hashtag(list, result, writer, hashtag) do
  	if Enum.find(list, fn x -> Enum.at(x, 0) == hashtag end) do
  		index = Enum.find_index(list, fn x -> Enum.at(x, 0) == hashtag end)
  		result = result ++ [writer] ++ Enum.at(list, index)
  		list = List.delete_at(list, index)
  		find_all_hashtag(list, result, writer, hashtag)
  	else
  		result
  	end
  end

  def handle_call({:query_mention_me, nickname_self}, _from, metadata) do
    tweets_list = Enum.at(metadata,1)
    tweets = Enum.map(tweets_list, fn x ->  writer = hd(x)
    										x = List.delete_at(x,0)
    										find_all_tweet(x, [], writer, nickname_self) end )
    tweets = delete_nil(tweets)
    {:reply,tweets,metadata}
  end

  def find_all_tweet(list, result, writer, nickname) do
  	if Enum.find(list, fn x -> Enum.at(x, 1) == nickname end) do
  		index = Enum.find_index(list, fn x -> Enum.at(x, 1) == nickname end)
  		result = result ++ [writer] ++ Enum.at(list, index)
  		list = List.delete_at(list, index)
  		find_all_tweet(list, result, writer, nickname)
  	else
  		result
  	end
  end

  def handle_cast({:new_subscribe, nickname_self, nickname_sub}, metadata) do
  	nickname_self = String.to_atom(nickname_self)
  	nickname_sub = String.to_atom(nickname_sub)
    index = Enum.find_index(Enum.at(metadata,2), fn x -> List.first(x) == nickname_self end)
    #IO.puts "index #{index}"
    subscribe_list = if index != nil do
    	Enum.at(Enum.at(metadata,2),index) ++ [nickname_sub]
    else
    	[nickname_self, nickname_sub]
    end
    #IO.puts "subscribe_list #{inspect subscribe_list}"
    metadata = if index != nil do    
    	[Enum.at(metadata,0), Enum.at(metadata,1), List.replace_at(Enum.at(metadata,2),index,subscribe_list)]
    else
    	[Enum.at(metadata,0), Enum.at(metadata,1), Enum.at(metadata,2) ++ subscribe_list]
    end
    {:noreply, metadata}  
  end

  def handle_cast({:send_tweet, nickname, mention, hashtag, tweet_content}, metadata) do
  	nickname = String.to_atom(nickname)
    index = Enum.find_index(Enum.at(metadata,1), fn x -> List.first(x) == nickname end)
    tweet_list = Enum.at(Enum.at(metadata,1),index) ++ [[hashtag, mention, tweet_content]]
    metadata = [Enum.at(metadata,0), List.replace_at(Enum.at(metadata,1),index,tweet_list),Enum.at(metadata,2)]
    {:noreply, metadata}
  end

#tweet_content is //user:original content
  def handle_cast({:retweet, nickname, tweet_content}, metadata) do
  	nickname = String.to_atom(nickname)
    index = Enum.find_index(Enum.at(metadata,1), fn x -> List.first(x) == nickname end)
    tweet_list = Enum.at(Enum.at(metadata,1),index) ++ [[nil, nil, tweet_content]]
    metadata = [Enum.at(metadata,0), List.replace_at(Enum.at(metadata,1),index,tweet_list),Enum.at(metadata,2)]
    {:noreply, metadata}  
  end

"""
  def handle_cast({:sign_up, new_name}, metadata) do
  	new_name = String.to_atom(new_name)
    usertweet_list = Enum.at(metadata,1) ++ [[new_name]]
    subscribe_list = Enum.at(metadata,2) ++ [[new_name]]
    metadata = [Enum.at(metadata,0), [usertweet_list], [subscribe_list]]
    {:noreply, metadata}  
  end
"""
  def handle_cast({:delete_account, account}, metadata) do
  	account = String.to_atom(account)
  	index = Enum.find_index(Enum.at(metadata,0), fn x -> x == account end)
    user_list = List.delete_at(Enum.at(metadata,0), index)
    index = Enum.find_index(Enum.at(metadata,1), fn x -> List.first(x) == account end)
    tweet_list = List.delete_at(Enum.at(metadata,1), index)
    index = Enum.find_index(Enum.at(metadata,2), fn x -> List.first(x) == account end)
    subscribe_list = List.delete_at(Enum.at(metadata,2), index)
    #IO.puts "subscribe_list #{inspect subscribe_list}"
    subscribe_list = Enum.map(subscribe_list, fn x -> (if Enum.find_index(x, fn y -> y == account end) do
    												  	 List.delete_at(x,Enum.find_index(x, fn y -> y == account end))
    												  	else
    												  		x
    												  	end) end)
    metadata = [user_list,tweet_list, subscribe_list]
    {:noreply, metadata}  
  end

  def delete_nil(list) do
  	if Enum.find(list, fn x -> x == [] end) do
  		index = Enum.find_index(list, fn x -> x == [] end)
  		list = List.delete_at(list,index)
  		delete_nil(list)
  	else
  		list
  	end
  end

end