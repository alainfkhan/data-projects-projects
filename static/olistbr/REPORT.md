# Report 

## Sales

Overview: 

- Order count
- GMV = (Total Product Revenue) + (Total Freight Revenue)
- AOV = GMV / (Order Count)
- AOV MoM %

Top (by total revenue):

- Product Categories
- Business Segments

Revenue by:

- Customer State
- Seller State

## Customers

An order is fulfilled when it is delivered.

An order is considered delivered when:

- `order_status` is `delivered`,
- or `order_delivered_customer_date` exists.

Monthly:

- new users
- repeat users
- cancellations
- unfulfilled orders
- average orders per user

Per user:

- expenditures
- orders
- concentration (pc share)

Top users in expenditures.

## Sellers

Monthly:

- new sellers
- repeat sellers

Per seller:

- revenue
- orders
- concentration (pc share)

## Funnel

## Logistics

The zip codes in the `geolocation` table seem to be an obfuscation of customer and seller locations.
There are lat/long coordinates that appear outside Brazil.

Monthly

- average delivery time
- late deliveries count
- pc of late deliveries

Delivery time by state