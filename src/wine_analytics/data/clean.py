import pandas as pd
from pathlib import Path

# Находим корень проекта от расположения этого файла
PROJECT_ROOT = Path(__file__).resolve().parents[3]
RAW_PATH = PROJECT_ROOT / "data" / "raw" / "winemag-data-130k-v2.csv"
PROCESSED_PATH = PROJECT_ROOT / "data" / "processed" / "wines_clean.csv"

# 1. Загружаем сырые данные
df = pd.read_csv(RAW_PATH, index_col=0)
print(f"Загружено строк: {len(df)}")

# 2. Удаляем строки, где нет критичных для анализа полей
df = df.dropna(subset=["country", "province", "variety"])
print(f"После удаления строк без country/province/variety: {len(df)}")

# 3. Заменяем неразрывные пробелы (\xa0) на обычные во всех текстовых колонках.
# Неразрывный пробел выглядит как обычный, но для SQL это другой символ: например,
# WHERE taster_name = 'Anne Krebiehl MW' без этой замены ничего не находит.
# strip() убирает пробелы по краям: иногда \xa0 стоит в конце значения ("A.R. Lenoble\xa0")
for col in df.select_dtypes(include="str").columns:
    df[col] = df[col].str.replace("\xa0", " ").str.strip()

# 4. Убираем полные дубликаты строк
before = len(df)
df = df.drop_duplicates()
print(f"Удалено дубликатов: {before - len(df)}")

# 5. Извлекаем год урожая из title: берём САМЫЙ ПОЗДНИЙ год вида 19xx/20xx.
# Кроме года урожая в названии бывают год основания винодельни ("Hazlitt 1852 Vineyards 2007")
# и год посадки лоз ("Domaine Dupré 2011 Vignes de 1935") — они всегда раньше урожая
years = df["title"].str.findall(r"\b(19\d{2}|20\d{2})\b")
df["vintage_year"] = years.apply(lambda ys: max(int(y) for y in ys) if ys else pd.NA)
df["vintage_year"] = pd.to_numeric(df["vintage_year"], errors="coerce")

# Год раньше 1900 или позже 2017 (год сбора данных) — точно не год урожая, оставляем пустым
mask = (df["vintage_year"] < 1900) | (df["vintage_year"] > 2017)
df.loc[mask, "vintage_year"] = pd.NA

# 6. Сохраняем результат
PROCESSED_PATH.parent.mkdir(parents=True, exist_ok=True)
df.to_csv(PROCESSED_PATH)
print(f"Сохранено в: {PROCESSED_PATH}")
print(f"Итоговый размер: {df.shape}")