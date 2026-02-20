```mermaid
flowchart LR
    h[hamlet.txt] --> cl1[Clean]
    m[macbeth.txt] --> cl2[Clean]

    cl1 --> co1[Count Words]
    cl2 --> co2[Count Words]

    co1 --> t1[Top 100]
    co2 --> t2[Top 100]

    t1 --> cmp[Compare]
    t2 --> cmp

    cmp --> mat[similarity_matrix.csv]
```
