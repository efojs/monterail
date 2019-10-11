# Ticketing system
1. Get info about an event
2. Get info about about available tickets
3. Purchase one (or more) of available tickets

## System
**Ruby**: 2.5.5  
**Rails**: 6.0  
**Database**: SQLite

### Usage
1. Clone: `$ git clone https://github.com/efojs/monterail.git`
2. Go to project folder: `$ cd monterail`  
  (if you use RVM it should create new or switch to existing gemset `ruby-2.5.5@rails6.0`)
3. Install: `$ bundle install`
4. Run: `$ rspec`


## API v1.0

### GET
1. `/api/v1_0/events` — events list
```
{
        [{
              "id": Integer,
              "name": String,
              "start_at": "yyyy-mm-dd hh:mm:ss",
              "end_at": "yyyy-mm-dd hh:mm:ss",
              "tickets_total": Integer,
              "tickets_sold": Integer,
              "ticket_price": Float,
              "created_at": "yyyy-mm-dd hh:mm:ss",
              "updated_at": "yyyy-mm-dd hh:mm:ss",
        },...]
}
```
2. `/api/v1_0/events/:event_id` — event description
```
{  
        {
              "id": Integer,
              "name": String,
              "start_at": "yyyy-mm-dd hh:mm:ss",
              "end_at": "yyyy-mm-dd hh:mm:ss",
              "tickets_total": Integer,
              "tickets_sold": Integer,
              "ticket_price": Float,
              "created_at": "yyyy-mm-dd hh:mm:ss",
              "updated_at": "yyyy-mm-dd hh:mm:ss",
        }
}
```
3. `/api/v1_0/orders/:order_id` — order description
```
{  
        {
              "id": Integer,
              "event_id": Integer,
              "tickets_amount": Integer,
              "status": "open"/"closed",
              "created_at": "yyyy-mm-dd hh:mm:ss",
              "updated_at": "yyyy-mm-dd hh:mm:ss",
              "expires_at": "yyyy-mm-dd hh:mm:ss",
              "sum": Float
        }
}
```
4. `/api/v1_0/orders/:order_id/tickets` — tickets list
```
{  
       [{     
             "id": Integer,
             "order_id": Integer,
             "key": String,              
             "created_at": "yyyy-mm-dd hh:mm:ss",
             "updated_at": "yyyy-mm-dd hh:mm:ss",
       },...]
}
```

### POST
1. `/api/v1_0/events/:event_id/book/:amount` — book requested amount of tickets
```
{  
        {
              "id": Integer,
              "event_id": Integer,
              "tickets_amount": Integer,
              "status": "open",
              "created_at": "yyyy-mm-dd hh:mm:ss",
              "updated_at": "yyyy-mm-dd hh:mm:ss",
              "expires_at": "yyyy-mm-dd hh:mm:ss",
              "sum": Float
        }
}

 # Errors:
{
        [
            "Requested amount of tickets ([Integer]) not available. Only [Integer] left."
        ]
}
```
2. `/api/v1_0/orders/:order_id/pay/:token` — pay by order ID and token
```
{  
        {     
              "id": Integer,
              "order_id": Integer,
              "key": String,              
              "created_at": "yyyy-mm-dd hh:mm:ss",
              "updated_at": "yyyy-mm-dd hh:mm:ss",
        }
}

 # Errors:
{
        [
            "[Order failed to close / Order does not exist]. During purchase something went wrong, no tickets bought, we returned you your money"
            / "Order is already closed"
            / "Card has been declined"
            / "Payment failed. Something went wrong with your transaction"
            / "Order does not exist (maybe it has expired). Please book another one"
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


**Reserves tickets:**
  - for 15 minutes,
  - or until the end of event, if less than 15 minutes left
    - show message that the event will end in X minutes
    - UI shows countdown to expiration time, when time expires form is disabled with message "Time is out, please book tickets again"

**Increases amount of sold tickets in the event**  
**Deleted after expiration (decreases number of sold tickets), if not closed**  

### Ticket
- order
- antifraud key (made of event name's hash and small random alphanumeric string, e.g.: 4517436092159794617we89f)

## Payment
`:token` used to simulate behaviour of payment system
### Before processing payment:  
  1. check if order still exists

### If successful (`token: "ok"`):  
  1. close order,
  2. create tickets,
  3. show tickets

### If succeeded, but order was already deleted (`token: "expired"`):
  1. money should be returned,
  2. UI should show message like "During purchase something went wrong, no tickets bought, we returned you your money"

### If failed:
  1. show error message
    1. card error (`token: "card_error"`)
    2. payment error (`token: "payment_error"`)
