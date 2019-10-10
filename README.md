# Ticketing system

## API v1.0
### GET
 - `/api/v1_0/events` — list events
 ```
{  
        "data" : [{
              "type": "events",
              "id": Integer,
              "attributes": {
                  "name": String,
                  "start_at": "yyyy-mm-dd hh:mm:ss",
                  "end_at": "yyyy-mm-dd hh:mm:ss",
                  "tickets_total": Integer,
                  "tickets_sold": Integer,
                  "ticket_price": Float
              }
        },...]
}
 ```
 - `/api/v1_0/events/[event_id]` — event description
 ```
{  
        "data" : {
              "type": "events",
              "id": Integer,
              "attributes": {
                  "name": String,
                  "start_at": "yyyy-mm-dd hh:mm:ss",
                  "end_at": "yyyy-mm-dd hh:mm:ss",
                  "tickets_total": Integer,
                  "tickets_sold": Integer,
                  "ticket_price": Float
              }
        }
}

 # Errors:
{
        "errors": [
           "Event does not exist"
        ]
}
 ```
 - `/api/v1_0/orders/[order_id]` — order description
```
{  
      "data" : {
           "type": "orders",
           "id": Integer,
           "attributes": {
               "status": "open"/"closed",
               "event_id": Integer,
               "tickets_amount": Integer,
               "sum": Integer,
               "expires_at": "yyyy-mm-dd hh:mm:ss"
           }
      }
}

  # Errors:
{
        "errors": [
            "Order does not exist"
        ]
}
```

### POST
- `/api/v1_0/events/[event_id]/book/[amount]` — book requested amount of tickets
```
{
        "data" : {
             "type": "orders",
             "id": Integer,
             "attributes": {
                 "status": "open",
                 "event_id": Integer,
                 "tickets_amount": Integer,
                 "sum": Integer,
                 "expires": "yyyy-mm-dd hh:mm:ss"
             }
        }
}

 # Errors:
{
        "errors": [
            "Requested amount of tickets ([Integer]) not available. Only [Integer] available."
        ]
}
```
- `/api/v1_0/orders/[order_id]/pay` — pay by order ID
```
{
        "data" : {
             "type": "orders",
             "id": Integer,
             "attributes": {
                 "status": "closed",
                 "event_id": Integer,
                 "tickets_amount": Integer,
                 "sum": Integer
             },
             "relationships": [{
                 "type": "tickets",
                 "id": Integer,
                 "attributes": {
                     "key": String,
                     "order_id": Integer,
                 }
               },...]
        }
}

 # Errors:
{
        "errors": [
            "Payment failed due to [error]"
            / "Order does not exist (maybe it has expired). Please book another one"
            / "During purchase something went wrong, no tickets bought, we returned you your money"
        ]
}
```

## Models
### Event
- name
- start date and time
- end date and time
- tickets total
- tickets sold
- ticket price

### Order
- status
  - open
  - closed
- event
- amount of tickets ordered
- expires_at

Reserves tickets:
- for 15 minutes,
- or until the end of event, if less than 15 minutes left
   - show message that the event will end in X minutes
- UI shows countdown to expiration time, when time expires form is disabled with message "Time is out, please book tickets again"

Increases amount of sold tickets  
Deleted after expiration (decreases number of sold tickets), if not closed

### Ticket
- order
- antifraud key (made of event name's hash and small random alphanumeric string, e.g.: 4517436092159794617we89f)

## Payment
Before processing payment:  
  1. check if order still exists

If successful:  
  1. close order,
  2. create tickets,
  3. show tickets

If failed:
  1. show error message

If payment was sent and successfully proceeded, but order was already deleted:
  1. money should be returned,
  2. UI should show message like "During purchase something went wrong, no tickets bought, we returned you your money"

Payment may fail:
  1. not enough money
  2. wrong credentials
  3. connection failure
