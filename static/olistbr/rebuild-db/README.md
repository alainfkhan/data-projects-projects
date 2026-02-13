# rebuild-db

## Notable analysis projects

- [Olist](https://github.com/alainfkhan/data-projects-projects/blob/main/static/olistbr/README.md)
  - [**rebuild-db**](https://github.com/alainfkhan/data-projects-projects/blob/main/static/olistbr/rebuild-db/README.md)
- [Restaurant Business Online](https://github.com/alainfkhan/data-projects-projects/blob/main/macos/bogacz-res/README.md)

---

- Running `rebuild-db` drops and rebuilds a staging database `olist_stg`, and inserts data from this project into the created tables.
- The created staging database `olist_stg` is intended to be copied and should not be used for analysis since it's susceptible to frequent rewrites and hence also to potential data loss.
- `rebuild-db` uses `uv` as the python package manager.

## Setup the virtual environment

Go to the project directory:

```bash
cd rebuild-db
```

Remember to deactivate any connected-to virtual environments:

```bash
deactivate
conda deactivate
```

Sync the environment using `uv`:

```bash
uv sync
```

## Rebuild the database by running `src`

Run `src` to rebuild the database:

```bash
make run
# or
uv run src
```

> [!NOTE]
>
> - You could be on debug mode.
> - To exit debug mode:
>   1. Go to [`src/__main__.py`](https://github.com/alainfkhan/data-projects-projects/blob/main/static/olistbr/rebuild-db/src/__main__.py).
>   2. Find the variable `execute` just after imports and before `def main() -> None:`.
>   3. Change the bool of `execute` from `False` to `True`.
>   4. Change the bools of any of the other debug variables as required.
>   5. Run `src` to rebuild the database.
>   6. Revert `execute` back to `False` to avoid any accidental rebuilds.
> - Do not use the created staging database for analysis.
> - Copy the staging database and use that for analysis.

### Running this program

![](../img/cmd_execute.gif)

<details>

<summary>View the database overview</summary>

```txt
Overview of database: 'olist_stg'
--------------------------------------------------
        Schemas
┏━━━━━━━━━━━━━┳━━━━━━━━┓
┃ Schema name ┃ Tables ┃
┡━━━━━━━━━━━━━╇━━━━━━━━┩
│ sales       │ 8      │
│ marketing   │ 2      │
│ logistics   │ 1      │
└─────────────┴────────┘
                              Tables
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┳━━━━━━━━━┳━━━━━━━━━┓
┃ Table name                                  ┃ Rows    ┃ Columns ┃
┡━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━╇━━━━━━━━━╇━━━━━━━━━┩
│ sales.dim_customers                         │ 99441   │ 5       │
│ sales.dim_sellers                           │ 3095    │ 4       │
│ sales.dim_product_category_name_translation │ 71      │ 2       │
│ sales.dim_products                          │ 32951   │ 9       │
│ sales.fact_orders                           │ 99441   │ 8       │
│ sales.fact_order_items                      │ 112650  │ 7       │
│ sales.fact_order_payments                   │ 103886  │ 5       │
│ sales.fact_order_reviews                    │ 99224   │ 7       │
│ marketing.fact_marketing_qualified_leads    │ 8000    │ 4       │
│ marketing.fact_closed_deals                 │ 842     │ 14      │
│ logistics.fact_geolocation                  │ 1000163 │ 6       │
└─────────────────────────────────────────────┴─────────┴─────────┘

```

</details>

- View an example output at [`docs/stdout/cmd_execute.txt`](docs/stdout/cmd_execute.txt).
- Running `src` generates dynamic sql commands that is sent to the connected database.
- The connection configuration file [`src/configs/connection.yml`](src/configs/connection.yml) defines the connection string used to connect to a server.
  - This can be configured by the user.
- The database configuration file [`src/configs/db_config.yml`](src/configs/db_config.yml) defines the table schemas for this dataset.
  - This configuration file was created manually. Column data types, and constraints were determined from a previous analysis on the dataset.
- The database overview queries the database as it is.
- Notice the file `olist_geolocation_dataset.csv` takes the longest time to process since it has the table with the most rows with `1000163` rows.

<details>

<summary>View the debug mode</summary>

#### In debug mode:

![](../img/cmd_debug.gif)

- View an example output at [`docs/stdout/cmd_debug.txt`](docs/stdout/cmd_debug.txt)
- The output in debug mode still shows the sql generated but is not executed to the server.

> [!NOTE]
>
> - The gif above shows running this program `rebuild-db` in debug mode (with `execute = False`)
> - The database overview that appears at the end queries the database as it is.
> - The reason it shows no tables is because this program was ran before the tables were created.
> - If there was a lone table currently inside in the database, the database overview would show it.

</details>

### Data validation

- An inference function was used to help the engineer determine a columns data type.
- The `infer_dtypes()` function from [`src/utils/infer.py`](src/utils/infer.py) inputs a dataframe and outputs an attributes table that describes each column in the dataframe that was inputted.
- View a current example in [`notebooks/table_attrs.ipynb`](notebooks/table_attrs.ipynb)

```py
df = pd.read_csv(filepath, dtype=object)
infer_dtype(df)
```

<div>
<style scoped>
    .dataframe tbody tr th:only-of-type {
        vertical-align: middle;
    }

    .dataframe tbody tr th {
        vertical-align: top;
    }

    .dataframe thead th {
        text-align: right;
    }`</style>`

<table border="1" class="dataframe">
  <thead>
    <tr style="text-align: right;">
      <th></th>
      <th>has_unique_entries</th>
      <th>has_nulls</th>
      <th>where_nulls</th>
      <th>total_nulls</th>
      <th>sorted_chars_used</th>
      <th>total_unique_chars_used</th>
      <th>has_ascii</th>
      <th>has_non_ascii</th>
      <th>has_prefix_zero</th>
      <th>dice_sim_to_ascii</th>
      <th>dice_sim_to_non_ascii</th>
      <th>min_str_value</th>
      <th>max_str_value</th>
      <th>entry_lengths</th>
      <th>total_unique_entry_lengths</th>
      <th>max_entry_length</th>
      <th>is_fixed_length</th>
      <th>chars_used_subset_of_numeric</th>
      <th>has_prefix_dash</th>
      <th>has_digits</th>
      <th>has_hex_digits</th>
      <th>has_decimal</th>
      <th>dice_sim_to_digits</th>
      <th>dice_sim_to_hex_digits</th>
      <th>min_numeric_value</th>
      <th>max_numeric_value</th>
      <th>has_dash</th>
      <th>has_colon</th>
      <th>has_space</th>
      <th>has_exactly_two_entries</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <th>customer_id</th>
      <td>1</td>
      <td>0</td>
      <td>[]</td>
      <td>0</td>
      <td>0123456789abcdef</td>
      <td>16</td>
      <td>1</td>
      <td>0</td>
      <td>1</td>
      <td>0.275862</td>
      <td>0.0</td>
      <td>00012a2ce6f8dcda20d059ce98491703</td>
      <td>ffffe8b65bbe3087b653a978c870db99</td>
      <td>[32]</td>
      <td>1</td>
      <td>32</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>1</td>
      <td>0</td>
      <td>0.769231</td>
      <td>0.842105</td>
      <td><NA></td>
      <td><NA></td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>customer_unique_id</th>
      <td>0</td>
      <td>0</td>
      <td>[]</td>
      <td>0</td>
      <td>0123456789abcdef</td>
      <td>16</td>
      <td>1</td>
      <td>0</td>
      <td>1</td>
      <td>0.275862</td>
      <td>0.0</td>
      <td>0000366f3b9a7992bf8c76cfdf3221e2</td>
      <td>ffffd2657e2aad2907e67c3e9daecbeb</td>
      <td>[32]</td>
      <td>1</td>
      <td>32</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>1</td>
      <td>0</td>
      <td>0.769231</td>
      <td>0.842105</td>
      <td><NA></td>
      <td><NA></td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>customer_zip_code_prefix</th>
      <td>0</td>
      <td>0</td>
      <td>[]</td>
      <td>0</td>
      <td>0123456789</td>
      <td>10</td>
      <td>1</td>
      <td>0</td>
      <td>1</td>
      <td>0.181818</td>
      <td>0.0</td>
      <td>01003</td>
      <td>99990</td>
      <td>[5]</td>
      <td>1</td>
      <td>5</td>
      <td>1</td>
      <td>1</td>
      <td>0</td>
      <td>1</td>
      <td>1</td>
      <td>0</td>
      <td>1.0</td>
      <td>0.625</td>
      <td>1003</td>
      <td>99990</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
    <tr>
      <th>customer_city</th>
      <td>0</td>
      <td>0</td>
      <td>[]</td>
      <td>0</td>
      <td>'-14abcdefghijklmnopqrstuvwxyz</td>
      <td>31</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0.473282</td>
      <td>0.0</td>
      <td>abadia dos dourados</td>
      <td>zortea</td>
      <td>[3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, ...</td>
      <td>28</td>
      <td>32</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>1</td>
      <td>0</td>
      <td>0.097561</td>
      <td>0.301887</td>
      <td><NA></td>
      <td><NA></td>
      <td>1</td>
      <td>0</td>
      <td>1</td>
      <td>0</td>
    </tr>
    <tr>
      <th>customer_state</th>
      <td>0</td>
      <td>0</td>
      <td>[]</td>
      <td>0</td>
      <td>ABCDEFGIJLMNOPRST</td>
      <td>17</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0.290598</td>
      <td>0.0</td>
      <td>AC</td>
      <td>TO</td>
      <td>[2]</td>
      <td>1</td>
      <td>2</td>
      <td>1</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>1</td>
      <td>0</td>
      <td>0.0</td>
      <td>0.307692</td>
      <td><NA></td>
      <td><NA></td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
      <td>0</td>
    </tr>
  </tbody>
</table>
</div>
