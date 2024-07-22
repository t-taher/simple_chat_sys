module Searchable
  extend ActiveSupport::Concern
  
  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks
  
    mapping do
      indexes :id, type: 'keyword'
      indexes :number, type: 'keyword'
      indexes :msg_body, type: 'text'
        
      indexes :chat do
        indexes :id, type: 'keyword'
        indexes :number, type: 'keyword'
        indexes :application_id, type: 'keyword'

        indexes :application do
          indexes :id, type: 'keyword'
          indexes :token, type: 'keyword'
        end
      end
    end
  
    def self.search(q, app_token, chat_number)
      query = {
        "query": {
          "bool": {
            "must": [
              {
                "wildcard": {
                  "msg_body": {
                    "value": "*#{q}*"
                  }
                }
              },
              {
                "bool": {
                  "must": [
                    {
                      "match": {
                        "chat.application.token": app_token
                      }
                    },
                    {
                      "match": {
                        "chat.number": chat_number
                      }
                    }
                  ]
                }
              }
            ]
          }
        }
      }
      self.__elasticsearch__.search(query).records.to_a
    
    end
    def as_indexed_json(options={})
      self.as_json(
        only: [:id, :number, :msg_body],
        include: {
          chat: { 
            only: [:id, :number, :application_id],
            include: {
              application: {
                only: [:id, :token],
              }
            }
          }
        }
      )
    end
  end
end