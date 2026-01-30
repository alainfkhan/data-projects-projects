import pandas as pd

# def lev_d(a: str, b: str) -> int:
#     """Levenshtein distance
#     measures the distance between two strings from doing operations:
#         insert
#         remove
#         replace

#     time: O(mn) quadratic
#     """
#     lena = len(a)
#     lenb = len(b)

#     if lenb == 0:
#         return lena

#     if lena == 0:
#         return lenb

#     heada = a[0]
#     headb = b[0]
#     taila = a[1:]
#     tailb = b[1:]

#     if heada == headb:
#         return lev_d(taila, tailb)

#     return 1 + min(lev_d(taila, b), lev_d(a, tailb), lev_d(taila, tailb))


# def sim_norm_lev_d(a: str, b: str) -> float:
#     """similarity normalised lev_d"""
#     lena = len(a)
#     lenb = len(b)

#     return 1 - lev_d(a, b) / max(lena, lenb)


# def dice_sim(A: set[str], B: set[str]) -> float:
#     """Dice similarity
#     |AnB| / (|A|+|B|/2) = 2*|AnB| / (|A|+|B|) in [0,1]
#     how much a set overlaps another set given their average size
#     complete coverage = 1
#     partial coverage = (0, 1)
#     no coverage = 0
#     """
#     return 2 * len(A.intersection(B)) / (len(A) + len(B))


# def get_max_ps(col: pd.Series) -> tuple[int, int]:
#     """get max precision and scale from a series
#     keep all entries as strings, count their lenghts, find max
#     turning to float lose precision
#     """
#     abs_col: pd.Series = col.astype(str).str.replace("-", "")
#     split: pd.Series = abs_col.str.split(".")

#     fractional_part: pd.Series = split.str[1]

#     max_scale: int = fractional_part.str.len().max()
#     max_precision: int = abs_col.str.replace(".", "").str.len().max()
#     return (int(max_precision), int(max_scale))
