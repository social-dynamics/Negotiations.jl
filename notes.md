---
title: model
...


# Model

$$
A := \text{list of agents}
$$

$$
n := \text{agent count}
$$

$$
i := \text{a particular agent i in A}
$$

$$
G := \text{set of parties (G for group, p is ambivalent)}
$$

$$
g_i := \text{agent i's party}
$$

$$
a_i \subseteq (g, O), \text{where g is a party and O is an opinion vector}
$$

$$
o \in \{-1, 0, 1\}
$$

$$
O \in o^{k \times n}, \text{where k is the number of considered issues}
$$

$$
O \in R^{n \times k},  \{o_{i,j} \in {-1, 0, 1} and 1 \leq i \leq n, 1 \leq j \leq k\}
$$

$$
g_i \subseteq (O, s), \text{where O is an opinion vector and s is the number of seats in the parliament}
$$

$$
\sigma(g) = s, \text{where s is the number of seats of party g in the parliament}
$$

$$
C \in Pot(G) wo {}, \text{where c i are the elements of C}
$$

$$
Pot(G) wo {} := \text{all viable coalitions}
$$

Similarity function

$$
S(a_i, a_j) := \frac{\parallel a_i.o - a_j.o \parallel}{2 * k}
$$
