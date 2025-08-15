import pandas as pd

# Tham số
K = 5
N = 10
M = 3  # số phần tử exhaustive dùng làm relevant cho mAP proxy

# Đọc csv (có cột: query,rank,filename,start_time,end_time,score)
ex = pd.read_csv("wise-test/exhaustive.csv")
ann = pd.read_csv("wise-test/ann.csv")

# Chuẩn hoá
ex = ex.sort_values(["query","rank"])
ann = ann.sort_values(["query","rank"])

queries = sorted(set(ex["query"]) & set(ann["query"]))

r0_vals, r1_vals, ap_vals = [], [], []

for q in queries:
    ex_q = ex[ex["query"]==q]
    ann_q = ann[ann["query"]==q]

    ex_topK = ex_q.head(K)["filename"].tolist()
    ann_topK = ann_q.head(K)["filename"].tolist()

    # R0@K: overlap(ANN_topK, EX_topK) / K
    r0 = len(set(ann_topK) & set(ex_topK)) / max(K,1)

    # R1@N,K: EX_topN có bao nhiêu nằm trong ANN_topK, chia N
    ex_topN = ex_q.head(N)["filename"].tolist()
    r1 = len(set(ex_topN) & set(ann_topK)) / max(N,1)

    # mAP proxy: relevant = EX_topM
    rel = set(ex_q.head(M)["filename"].tolist())
    hits, prec_sum = 0, 0.0
    for i, fn in enumerate(ann_q["filename"].tolist(), start=1):
        if fn in rel:
            hits += 1
            prec_sum += hits / i
    ap = (prec_sum / len(rel)) if len(rel) > 0 else 0.0

    r0_vals.append(r0)
    r1_vals.append(r1)
    ap_vals.append(ap)

print(f"Recall0@{K}: {sum(r0_vals)/len(r0_vals):.4f}")
print(f"Recall1@{N},{K}: {sum(r1_vals)/len(r1_vals):.4f}")
print(f"mAP (proxy vs exhaustive top-{M}): {sum(ap_vals)/len(ap_vals):.4f}")