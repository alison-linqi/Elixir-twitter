defmodule Twitter.Init do
	alias Twitter.Data.User
	alias Twitter.Data.Tweet
	alias Twitter.Repo

	def create_n_users(usernum, msgnum) when usernum == 0 do nil end
	def create_n_users(usernum, msgnum) when usernum > 0 do
		name = "user" <> Integer.to_string(usernum)
		if Twitter.Client.start_link(name, "123456") != nil do
			%User{} |> User.changeset(%{userid: name, password: "123456"}) |> Repo.insert()
			create_msg(msgnum, name)
			create_n_users(usernum-1, msgnum)
		else
			create_n_users(usernum-1, msgnum)
		end
	end

	def create_msg(msgnum, name) do
		if msgnum > 0 do
			content = "#DOS tweet No." <> Integer.to_string(msgnum)
			Twitter.Client.send_tweet(name, content)
			%Tweet{} |> Tweet.changeset(%{writer: name, hashtag: "DOS", content: content}) |> Repo.insert()
			IO.puts "@@@@@"
			create_msg(msgnum-1, name)
		else
			IO.puts "    " <> name <> " msg creation finishied."
		end
	end

	def create_list(list, n) do
		if n > 0 do
			list = list ++ [n]
			create_list(list, n-1)
		else
			list
		end
	end
end