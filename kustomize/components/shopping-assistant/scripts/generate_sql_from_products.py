
import json

table_name = "catalog_items"
fields = [
    'id', 'name', 'description', 'picture',
    'price_usd_currency_code', 'price_usd_units', 'price_usd_nanos',
    'categories'
]

with open("products.json", 'r') as f:
    data = json.load(f)

for product in data['products']:
    columns = ', '.join(fields)
    placeholders = ', '.join(['{}'] * len(fields))
    sql = f"INSERT INTO {table_name} ({columns}) VALUES ({placeholders});"

    product['name'] = product['name'].replace("'", "")
    product['description'] = product['description'].replace("'", "")

    escaped_values = (
        f"'{product['id']}'",
        f"'{product['name']}'",
        f"'{product['description']}'",
        f"'{product['picture']}'",
        f"'{product['priceUsd']['currencyCode']}'",
        product['priceUsd']['units'],
        product['priceUsd']['nanos'],
        f"'{','.join(product['categories'])}'"
    )

    print(sql.format(*escaped_values))
