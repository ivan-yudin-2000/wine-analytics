import os
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from dotenv import load_dotenv
from matplotlib.ticker import FuncFormatter
from sqlalchemy import create_engine

PROJECT_ROOT = Path(__file__).resolve().parents[3]
FIGURE_PATH = PROJECT_ROOT / "reports" / "figures" / "price_vs_points.png"

# Подключаемся к базе так же, как в load_to_postgres.py
load_dotenv(PROJECT_ROOT / ".env")
connection_string = (
    f"postgresql+psycopg://{os.getenv('DB_USER')}:{os.getenv('DB_PASSWORD')}"
    f"@{os.getenv('DB_HOST')}:{os.getenv('DB_PORT')}/{os.getenv('DB_NAME')}"
)
engine = create_engine(connection_string)

df = pd.read_sql("SELECT price, points FROM wines WHERE price > 0", engine)
print(f"Вин с ценой: {len(df)}")

# Корреляции для подписей на графике
r_raw = df["price"].corr(df["points"])
r_log = np.log(df["price"]).corr(df["points"])

# Средняя оценка по группам, где каждая следующая дороже в 2 раза (как в SQL-запросе 3).
# Группы, где меньше 20 вин, не рисуем: среднее по ним ненадёжно
df["bucket"] = 2 ** np.floor(np.log2(df["price"]))
groups = df.groupby("bucket").agg(price=("price", "median"), points=("points", "mean"), n=("points", "size"))
groups = groups[groups["n"] >= 20]

# Оценки целые (80, 81, ...), поэтому точки лежат полосками и перекрывают друг друга.
# Небольшой случайный сдвиг по вертикали ("jitter") разносит их, чтобы была видна плотность
rng = np.random.default_rng(42)
jittered_points = df["points"] + rng.uniform(-0.35, 0.35, len(df))

# Цвета: точки — синий, линия средних — основной цвет текста, сетка — светло-серая
DOT_COLOR = "#2a78d6"
INK = "#0b0b0b"
INK_SECONDARY = "#52514e"
GRID = "#e4e3df"
SURFACE = "#fcfcfb"

plt.rcParams.update({
    "font.family": "DejaVu Sans",
    "font.size": 10,
    "axes.edgecolor": GRID,
    "axes.labelcolor": INK_SECONDARY,
    "xtick.color": INK_SECONDARY,
    "ytick.color": INK_SECONDARY,
})

fig, axes = plt.subplots(1, 2, figsize=(12, 5), sharey=True, facecolor=SURFACE)

panels = [
    (axes[0], "linear", f"Цена как есть: r = {r_raw:.2f}"),
    (axes[1], "log", f"Логарифм цены: r = {r_log:.2f}"),
]
for ax, xscale, title in panels:
    ax.set_facecolor(SURFACE)
    ax.scatter(df["price"], jittered_points, s=3, color=DOT_COLOR, alpha=0.06, linewidths=0, rasterized=True)
    ax.plot(groups["price"], groups["points"], color=INK, linewidth=2, marker="o", markersize=6,
            markeredgecolor=SURFACE, markeredgewidth=2, zorder=3)

    ax.set_xscale(xscale)
    ax.set_title(title, loc="left", color=INK, fontsize=12, pad=10)
    ax.set_xlabel("Цена, $" + (" (логарифмическая шкала)" if xscale == "log" else ""))
    ax.grid(True, color=GRID, linewidth=1)
    ax.set_axisbelow(True)
    for side in ("top", "right"):
        ax.spines[side].set_visible(False)

axes[0].set_ylabel("Оценка, баллы")
axes[0].set_xlim(0, 3400)
axes[1].xaxis.set_major_formatter(FuncFormatter(lambda x, _: f"{x:,.0f}".replace(",", " ")))
axes[1].set_xticks([4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048])
axes[1].minorticks_off()

# Подпись к линии средних, без отдельной легенды
last = groups.iloc[-1]
axes[1].annotate("средняя оценка\nв ценовой группе", xy=(last["price"], last["points"]),
                 xytext=(-10, 18), textcoords="offset points", ha="right", color=INK, fontsize=9)

fig.suptitle("Чем дороже вино, тем выше оценка — но связь видна только в «разах», а не в долларах",
             x=0.01, ha="left", color=INK, fontsize=13)
n_wines = f"{len(df):,}".replace(",", " ")
fig.text(0.01, 0.005, f"Источник: WineEnthusiast, {n_wines} вин с указанной ценой. Каждая точка — одно вино; оценки чуть разнесены по вертикали, чтобы точки не сливались.",
         color=INK_SECONDARY, fontsize=8.5)
fig.tight_layout(rect=(0, 0.03, 1, 0.97))

FIGURE_PATH.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(FIGURE_PATH, dpi=150, facecolor=SURFACE)
print(f"Сохранено в: {FIGURE_PATH}")
