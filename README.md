Cadinsor 0.1.0
===
## What is Cadinsor?
Cadinsor provides OAuth like authentication to validate requests from your client apps to your backend Rails application. It can be easily mounted onto any application as it is a Rails engine. Currently supports both JSON and XML formats.

## Setup Instructions
  Add the cadinsor gem your gem file and then run the install generator. The installer will ask you would like to mount the engine.


    gem "cadinsor"
    $ rails g cadinsor:install
    $ rake db:migrate

## So how does it work?
Every request that is authenticated through Cadinsor must possess among it's parameters:

  1. A valid server issued key

  2. A valid app id

  3. A proper request signature

### Key Components
  * **An APP ID/ Secret**: Each client application has a unique APP ID and an "APP Secret" string. The app id is sent as part of every request from the client app. The app secret is not sent with the request, and is instead used to build the request signature (explained below).
  Cadinsor has very helpful rake tasks for you to manager your apps. Please be warned that the client_app tasks are interactive and cannot be run in a background job. You may run the following rake tasks:

      rake cadinsor:client_app:create         # Add a new client app
      rake cadinsor:client_app:delete         # Delete App
      rake cadinsor:client_app:edit_secret    # Edit App Secret
      rake cadinsor:client_app:list           # List all client apps with their secrets

  * **A Server Issued Key/ Key Fetch API**: In order to keep each request from the app independent, a server issued unique key string is sent along with request. A key is obtained by making a call the Key Fetch API. It is a public API and requires no parameters except an optional app id. The key has a time bound expiry (default = 5mins, specified in the initializer) and is invalidated after each request to the backend application.

    + Assuming your engine is mounted at /cadinsor, you may get a new key by visiting <root_url>/cadinsor/api_keys/create.json
    + Assuming your engine is mounted at /cadinsor, you may view the status of your key by visiting <root_url>/cadinsor/api_keys/show.json?key=<key value here\>

### Building the request signature at the client side
All the request parameters are sortd in alphabetical order and a request string is obtained by concatenating the corresponding values of these paremeters. To this string, the app secret and an SHA2 (256 bit) hash is computed of this string. This signature is also sent with every request to the server.
Ex: Consider a simple login request with the following parameters:

  1. user_name: lewstherin
  2. password: thedragon
  3. key: N1ilN8qZmOXodohO-9IRvpxZmVDY_Zg8P7r9JoDpFs4
  4. app_id: 2

In alphabetical order, these parameters become app_id, key, password and user_name. Assuming the app secret is "CaraianCaldazar!", our request string becomes "2N1ilN8qZmOXodohO-9IRvpxZmVDY_Zg8P7r9JoDpFs4thedragonlewstherinCaraianCaldazar!". Now the SHA2 hash of this string is "ab71fc84351c4cdfd23c31ea2ce4133b38cd3c21cfee48d3d15501e726c16734" and this is sent along with the request as the parameter signature.
At the server end, Cadinsor will rebuild this signature and check if it matches with the input signature. If it does, it means the client has sent a valid app secret and thus the request is from a trusted source.

In case you have nested hashes, flatten them by appending the outer hash key as a prefix, and then sort the keys to build a signature.
Ex: If your input params is as follows, cadinsor computes the signature of the flattened hash shown below.

    params = {:key=>"aslkaslkas", :signature=>"askjaskdskjdasklfj2103", :user=>{:id=>1, :email=>"a@b.com"}, :post=>{:title=>"rails_layout", :author=>"lewstherin", :comments=>{:author=>"Lews Therin", :date=>"14012014", :desc=>"This is a dummy comment"}}}

    flattened_hash = {"key"=>"aslkaslkas", "signature"=>"askjaskdskjdasklfj2103", "user_id"=>1, "user_email"=>"a@b.com", "post_title"=>"rails_layout", "post_author"=>"lewstherin", "post_comments_author"=>"Lews Therin", "post_comments_date"=>"14012014", "post_comments_desc"=>"This is a dummy comment"}


### Validating your requests at the controller side

You can validate your requests by the either placing a call to the **check_request_with_cadinsor** method in the before_filter method of your controller or by making an explicit call within your method. Take a look at the following code snippet (same code as in the test/dummy application):

    class CadinsorTestsController < ApplicationController

      before_filter :check_request_with_cadinsor, except: [:inside_method_check, :do_not_check]

      def default_check
        respond_to do  |format|
          format.json {render :action => 'do_not_check', :format => 'json'}
          format.xml {render :action => 'do_not_check', :format => 'xml'}
        end
      end

      def inside_method_check
        check_request_with_cadinsor
        respond_to do  |format|
          format.json {render :action => 'do_not_check', :format => 'json'}
          format.xml {render :action => 'do_not_check', :format => 'xml'}
        end
      end

      def do_not_check
        respond_to do  |format|
          format.json {render :action => 'do_not_check', :format => 'json'}
          format.xml {render :action => 'do_not_check', :format => 'xml'}
        end
      end
    end

### Options while calling the *check_request_with_cadinsor_method*

  1. If you do not want the cadinsor to check the params hash, but would like to check some other hash, you can do that by calling the method as follows:

      check_request_with_cadinsor(target_params: params[user])

  2. You can disable key checking altogether by:

      check_request_with_cadinsor(ignore_api_key_check: true)

## Action Items

  1. Add tests
  2. Improve this documentation

## License
[MIT License](http://opensource.org/licenses/MIT)