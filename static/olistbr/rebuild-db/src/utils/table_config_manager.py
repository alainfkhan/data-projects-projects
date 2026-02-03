from pathlib import Path
from typing import Dict, List, Any

from pydantic import BaseModel
import yaml

from src.utils.paths import CONFIGS_PATH

# types
# class SKInfo(BaseModel):
#     seed: int
#     increment: int

# class ColumnInfo(BaseModel):
#     dtype: str
#     nullable: bool
#     sk: SKInfo

# class Constraints(BaseModel):
#     pk: Dict[str, Any]
#     fk: Dict[str, Any]
#     unique: Dict[str, Any]

# class TableConfig(BaseModel):
#     filename: str
#     type: str
#     columns: List[Dict[str, ColumnInfo]]
#     constraints: Constraints

# class SchemaConfig(BaseModel):
#     pass


class TablesConfigManager:
    """Manages tables.yml"""

    def __init__(self, tables_config, db: str) -> None:
        self.tables_config = tables_config
        self.db = db
        pass

    def list_schemas(self) -> list[str]:
        """"""
        pass

    def list_tables(self) -> list[str]:
        """"""
        pass
