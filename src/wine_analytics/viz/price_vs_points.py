import os
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

PROJECT_ROOT = Path(__file__).resolve().parents[3]
FIGURE_PATH = PROJECT_ROOT / "reports" / "figures" / "price_vs_points.png"

# Подключаемся к базе так же, как в load_to_postgres.py
load_dotenv(PROJECT_ROOT / ".env")
db_user = os.getenv("DB_USER")
db_password = os.getenv("DB_PASSWORD")
db_host = os.getenv("DB_HOST")
db_port = os.getenv("DB_PORT")
db_name = os.getenv("DB_NAME")

connection_string = f"postgresql+psycopg://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
engine = create_engine(connection_string)

df = pd.read_sql("SELECT price, points FROM wines WHERE price > 0", engine)

# Корреляция Пирсона: на цене как есть и на логарифме цены
r_raw = df["price"].corr(df["points"])
r_log = np.log(df["price"]).corr(df["points"])
print(f"Пирсон, цена как есть: {r_raw:.2f}")
print(f"Пирсон, логарифм цены: {r_log:.2f}")

# Две панели с одними и теми же данными, отличается только шкала цены
fig, (ax_raw, ax_log) = plt.subplots(1, 2, figsize=(12, 5), sharey=True)

# alpha — прозрачность: где вин много, точки накладываются и цвет становится темнее
ax_raw.scatter(df["price"], df["points"], s=5, alpha=0.05)
ax_raw.set_title(f"Цена как есть: r = {r_raw:.2f}")
ax_raw.set_xlabel("Цена, $")
ax_raw.set_ylabel("Оценка, баллы")

# На логарифмической шкале одинаковое расстояние = одинаковое «во сколько раз дороже»
ax_log.scatter(df["price"], df["points"], s=5, alpha=0.05)
ax_log.set_xscale("log")
ticks = [5, 10, 20, 50, 100, 200, 500, 1000, 2000]
ax_log.set_xticks(ticks, labels=[str(t) for t in ticks])
ax_log.minorticks_off()
ax_log.set_title(f"Логарифм цены: r = {r_log:.2f}")
ax_log.set_xlabel("Цена, $ (логарифмическая шкала)")

fig.suptitle("Связь цены и оценки вина")
fig.tight_layout()

FIGURE_PATH.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(FIGURE_PATH, dpi=150)
print(f"Сохранено в: {FIGURE_PATH}")
