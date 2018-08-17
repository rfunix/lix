Application.put_env(:lix, :max_number_of_messages, 2)
Application.put_env(:lix, :visibility_timeout, 0.30)
ExUnit.start()
