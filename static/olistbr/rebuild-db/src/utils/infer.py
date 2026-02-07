import string

import pandas as pd
from pandas import DataFrame

from src.utils.measures import dice_sim


def infer_dtypes(df: DataFrame) -> DataFrame:
    """
    df -> out_df
    originally intended to fully infer (end-to-end) a cols datatype from its attributes
    incomplete
    currently being used as an aid for the engineer to determine col datatypes from its attributes
    can compartmentalise
    """

    def is_chars_in_string(chars: str, parent_string: str) -> bool:
        if set(chars).intersection(set(parent_string)):
            return True

        return False

    # TODO: add: chars_used_subset_of_hex_digits
    # TODO: add: is_numeric_float
    out_df = pd.DataFrame(
        index=df.columns,
        columns=[
            # keys
            "has_unique_entries",
            # nulls
            "has_nulls",
            "where_nulls",
            "total_nulls",
            # chars
            "sorted_chars_used",
            "total_unique_chars_used",
            "has_ascii",
            "has_non_ascii",
            "has_prefix_zero",
            "dice_sim_to_ascii",
            "dice_sim_to_non_ascii",
            "min_str_value",
            "max_str_value",
            "entry_lengths",
            "total_unique_entry_lengths",
            "max_entry_length",
            "is_fixed_length",
            # numeric
            "chars_used_subset_of_numeric",
            "has_prefix_dash",
            "has_digits",
            "has_hex_digits",
            "has_decimal",
            "dice_sim_to_digits",
            "dice_sim_to_hex_digits",
            "min_numeric_value",
            "max_numeric_value",
            # datetime
            "has_dash",
            "has_colon",
            "has_space",
            # bit
            "has_exactly_two_entries",
        ],
    )

    cols = df.columns

    for col in cols:
        print(col)

        # global vars
        clean_series = df[col].dropna()
        chars_used: set[str] = set("".join(clean_series.astype(str)))
        sorted_chars_used: str = "".join(sorted(chars_used))

        # keys ==================================================
        out_df.loc[col, "has_unique_entries"] = 1 if clean_series.is_unique else 0

        # nulls ==================================================
        where_null = df[col].isnull()

        out_df.loc[col, "has_nulls"] = 1 if where_null.any() else 0
        out_df.loc[col, "where_nulls"] = df[where_null].index.tolist()
        out_df.loc[col, "total_nulls"] = where_null.sum()

        # chars ==================================================
        # if col chars > ascii when col chars - ascii > 0
        excess_ascii: set[str] = chars_used - set(string.printable)
        entry_lengths = sorted(clean_series.astype(str).str.len().unique().tolist())

        out_df.loc[col, "sorted_chars_used"] = sorted_chars_used
        out_df.loc[col, "total_unique_chars_used"] = len(sorted_chars_used)
        out_df.loc[col, "has_ascii"] = (
            1
            if is_chars_in_string(
                string.printable,
                sorted_chars_used,
            )
            else 0
        )
        out_df.loc[col, "has_non_ascii"] = 1 if excess_ascii else 0
        out_df.loc[col, "has_prefix_zero"] = (
            1 if clean_series.astype(str).str.startswith("0").any() else 0
        )
        out_df.loc[col, "dice_sim_to_ascii"] = dice_sim(
            set(string.printable),
            chars_used,
        )
        out_df.loc[col, "dice_sim_to_non_ascii"] = dice_sim(
            excess_ascii,
            chars_used,
        )
        out_df.loc[col, "min_str_value"] = min(clean_series)
        out_df.loc[col, "max_str_value"] = max(clean_series)
        out_df.loc[col, "entry_lengths"] = entry_lengths
        out_df.loc[col, "total_unique_entry_lengths"] = len(entry_lengths)
        out_df.loc[col, "max_entry_length"] = max(entry_lengths)
        out_df.loc[col, "is_fixed_length"] = 1 if len(entry_lengths) == 1 else 0

        # numeric ==================================================
        str_numeric = string.digits + "-."

        out_df.loc[col, "chars_used_subset_of_numeric"] = (
            1 if chars_used.issubset(str_numeric) else 0
        )
        out_df.loc[col, "has_prefix_dash"] = (
            1 if clean_series.astype(str).str.startswith("-").any() else 0
        )
        out_df.loc[col, "has_digits"] = (
            1
            if is_chars_in_string(
                string.digits,
                sorted_chars_used,
            )
            else 0
        )
        out_df.loc[col, "has_hex_digits"] = (
            1
            if is_chars_in_string(
                string.hexdigits,
                sorted_chars_used,
            )
            else 0
        )
        out_df.loc[col, "has_decimal"] = (
            1
            if is_chars_in_string(
                ".",
                sorted_chars_used,
            )
            else 0
        )
        out_df.loc[col, "dice_sim_to_digits"] = dice_sim(
            set(string.digits),
            chars_used,
        )
        out_df.loc[col, "dice_sim_to_hex_digits"] = dice_sim(
            set(string.hexdigits),
            chars_used,
        )

        val = pd.to_numeric(clean_series, errors="coerce")
        numeric_min = val.min()
        numeric_max = val.max()
        out_df.loc[col, "min_numeric_value"] = (
            numeric_min if pd.notnull(numeric_min) else pd.NA
        )
        out_df.loc[col, "max_numeric_value"] = (
            numeric_max if pd.notnull(numeric_max) else pd.NA
        )

        # datetime ==================================================
        out_df.loc[col, "has_dash"] = (
            1
            if is_chars_in_string(
                "-",
                sorted_chars_used,
            )
            else 0
        )
        out_df.loc[col, "has_colon"] = (
            1
            if is_chars_in_string(
                ":",
                sorted_chars_used,
            )
            else 0
        )
        out_df.loc[col, "has_space"] = (
            1
            if is_chars_in_string(
                " ",
                sorted_chars_used,
            )
            else 0
        )

        # bit ==================================================
        unique_entries = clean_series.unique()
        out_df.loc[col, "has_exactly_two_entries"] = (
            1 if len(unique_entries) == 2 else 0
        )
    return out_df
