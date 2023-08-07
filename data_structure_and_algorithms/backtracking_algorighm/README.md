# Backtracking Algorithm

Other name: Heuristic(尝试法)

> Basic idea: Find a path to go, Go stragt if can continue, otherwise back and then try another way.


> Essence: The essence of backtracking algorithm is depth first exhaustion，but the not same is it uses a pruning function to cut some nodes that cannot reach the final state (that is, the answer state), thereby reducing the generation of state space tree nodes.

> Use: 8 queen problem, Maze.

回溯法是一个既带有系统性又带有跳跃性的的搜索算法。它在包含问题的所有解的解空间树中，按照深度优先的策略，从根结点出发搜索解空间树。算法搜索至解空间树的任一结点时，**总是先判断**该结点是否**肯定不包含问题的解**。如果肯定不包含，则跳过对以该结点为根的子树的系统搜索，逐层向其祖先结点回溯。否则，进入该子树，继续按深度优先的策略进行搜索。回溯法在用来求问题的所有解时，要回溯到根，且根结点的所有子树都已被搜索遍才结束。而回溯法在用来求问题的任一解时，只要搜索到问题的一个解就可以结束。