"""
The tables in this kaggle dataset are from https://www.restaurantbusinessonline.com
from the year 2020.

It's possible to webscrape other years.
"""

from datetime import datetime

current_year = datetime.now().year

# query year
# year interested in
q_year = 2020
website = "https://www.restaurantbusinessonline.com"
query = f"year={q_year}"

f50 = f"{website}/future-50-{q_year}?{query}#data-table"
i100 = f"{website}/top-100-independents-{q_year}?{query}#data-table"

t250_page_max = 4
t250: list[str] = [
    f"{website}/top-500-{q_year}?{query}&page={page}#data-table"
    for page in range(0, t250_page_max + 1)
]
# eventhough the url says top-500, there are at most 5 pages of 50 entries = 250 entries

table_sources: dict[str, str | list[str]] = {
    "future-50": f50,
    "top-100-independents": i100,
    "top-250": t250,
}

print(table_sources)
