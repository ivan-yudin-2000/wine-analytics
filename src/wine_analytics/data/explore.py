import pandas as pd
from pathlib import Path

# Находим корень проекта, отталкиваясь от расположения ЭТОГО файла
PROJECT_ROOT = Path(__file__).resolve().parents[3]
DATA_PATH = PROJECT_ROOT / "data" / "raw" / "winemag-data-130k-v2.csv"

df = pd.read_csv(DATA_PATH, index_col=0)

print("Размер таблицы (строки, колонки):", df.shape)
print("\nТипы колонок:")
print(df.dtypes)
print("\nПропуски по колонкам:")
print(df.isna().sum())