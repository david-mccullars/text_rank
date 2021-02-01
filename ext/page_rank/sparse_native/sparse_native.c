#include <ruby.h>
#include <math.h>

struct NodeListStruct;
typedef struct NodeListStruct* NodeList;

typedef struct NodeListStruct {
  struct NodeStruct *node;
  struct NodeListStruct *next;
} NodeListStruct;

const size_t NODE_LIST_SIZE = sizeof(NodeListStruct);

//////////////////////////////////////////////////////////////////////////////////////

struct EdgeListStruct;
typedef struct EdgeListStruct* EdgeList;

typedef struct EdgeListStruct {
  struct EdgeStruct *edge;
  struct EdgeListStruct *next;
} EdgeListStruct;

const size_t EDGE_LIST_SIZE = sizeof(EdgeListStruct);

//////////////////////////////////////////////////////////////////////////////////////

struct NodeStruct;
typedef struct NodeStruct* Node;

typedef struct NodeStruct {
  EdgeList source_edges;
  VALUE label;
  double prev_rank;
  double rank;
  double outbound_weight_total;
} NodeStruct;

const size_t NODE_SIZE = sizeof(NodeStruct);

//////////////////////////////////////////////////////////////////////////////////////

struct EdgeStruct;
typedef struct EdgeStruct* Edge;

typedef struct EdgeStruct {
  Node source;
  double weight;
} EdgeStruct;

const size_t EDGE_SIZE = sizeof(EdgeStruct);

//////////////////////////////////////////////////////////////////////////////////////

struct GraphStruct;
typedef struct GraphStruct* Graph;

typedef struct GraphStruct {
  unsigned long node_count;
  NodeList nodes;
  NodeList dangling_nodes;
  st_table *node_lookup;
} GraphStruct;

const size_t GRAPH_SIZE = sizeof(GraphStruct);

//////////////////////////////////////////////////////////////////////////////////////

void free_graph(void *data);
void free_node(Node n);
void free_node_list(NodeList nodes, void (*free_item)(Node));
void free_edge(Edge e);
void free_edge_list(EdgeList edges, void (*free_item)(Edge));

void free_graph(void *data) {
  Graph g = (Graph)data;
  free_node_list(g->nodes, free_node);
  free_node_list(g->dangling_nodes, NULL);
  // node_lookup allocated by rb_hash_tbl
  free(g);
}

void free_node(Node n) {
  free_edge_list(n->source_edges, free_edge);
  free(n);
}

void free_node_list(NodeList nodes, void (*free_item)(Node)) {
  NodeList tmp;
  while (nodes != NULL) {
    tmp = nodes;
    nodes = nodes->next;
    if (free_item) {
      free_item(tmp->node);
    }
    free(tmp);
  }
}

void free_edge(Edge e) {
  // Assume source node was allocated elsewhere and will be free'd elsewhere
  free(e);
}

void free_edge_list(EdgeList edges, void (*free_item)(Edge)) {
  EdgeList tmp;
  while (edges != NULL) {
    tmp = edges;
    edges = edges->next;
    if (free_item) {
      free_item(tmp->edge);
    }
    free(tmp);
  }
}

//////////////////////////////////////////////////////////////////////////////////////

Node add_node(Graph g, VALUE label);
Node add_dangling_node(Graph g, Node n);
Edge add_edge(Node source, Node destination, double weight);
Edge add_edge_with_labels(Graph g, VALUE source_label, VALUE dest_label, double weight);
Node lookup_node(Graph g, VALUE label);

Node add_node(Graph g, VALUE label) {
  NodeList tmp = malloc(NODE_LIST_SIZE);

  tmp->node = malloc(NODE_SIZE);
  tmp->node->label = label;
  tmp->node->source_edges = NULL;
  tmp->node->rank = 0.0;
  tmp->node->prev_rank = 0.0;
  tmp->node->outbound_weight_total = 0.0;

  tmp->next = g->nodes;
  g->nodes = tmp;
  g->node_count += 1;

  return tmp->node;
}

Node add_dangling_node(Graph g, Node n) {
  NodeList tmp = malloc(NODE_LIST_SIZE);

  tmp->node = n;
  tmp->next = g->dangling_nodes;
  g->dangling_nodes = tmp;

  return n;
}

Edge add_edge(Node source, Node destination, double weight) {
  EdgeList tmp = malloc(EDGE_LIST_SIZE);

  tmp->edge = malloc(EDGE_SIZE);
  tmp->edge->source = source;
  tmp->edge->weight = weight;

  tmp->next = destination->source_edges;
  destination->source_edges = tmp;
  source->outbound_weight_total += weight;

  return tmp->edge;
}

Edge add_edge_with_labels(Graph g, VALUE source_label, VALUE dest_label, double weight) {
  Node source, dest;

  source = lookup_node(g, source_label);
  dest = lookup_node(g, dest_label);

  return add_edge(source, dest, weight);
}

Node lookup_node(Graph g, VALUE label) {
  Node n;

  if (!st_lookup(g->node_lookup, (st_data_t)label, (st_data_t *)&n)) {
    n = add_node(g, label);
    st_add_direct(g->node_lookup, (st_data_t)label, (st_data_t)n);
  }
  return n;
}

//////////////////////////////////////////////////////////////////////////////////////

void calculate_start(Graph g) {
  NodeList nodes;
  Node source, destination;
  EdgeList edges;
  Edge e;

  for (nodes = g->nodes; nodes != NULL; nodes = nodes->next) {
    destination = nodes->node;

    // If there is no outband, this is a "dangling" node
    if (destination->outbound_weight_total == 0.0) {
      add_dangling_node(g, destination);
    }

    // Normalize all source edge weights
    for (edges = destination->source_edges; edges != NULL; edges = edges->next) {
      e = edges->edge;
      source = e->source;
      e->weight = e->weight / source->outbound_weight_total;
    }

    // Set the initial rank
    destination->prev_rank = 0;
    destination->rank = 1.0 / g->node_count;
  }
}

void calculate_step(Graph g, double damping) {
  NodeList nodes, dangling_nodes;
  Node source, destination;
  EdgeList edges;
  Edge e;
  double sum;

  // Set prev rank to rank for all nodes
  for (nodes = g->nodes; nodes != NULL; nodes = nodes->next) {
    destination = nodes->node;
    destination->prev_rank = destination->rank;
  }

  // Re-destribute the rankings according to weight
  for (nodes = g->nodes; nodes != NULL; nodes = nodes->next) {
    destination = nodes->node;
    sum = 0.0;
    for (edges = destination->source_edges; edges != NULL; edges = edges->next) {
      e = edges->edge;
      source = e->source;
      sum += source->prev_rank * e->weight;
    }
    for (dangling_nodes = g->dangling_nodes; dangling_nodes != NULL; dangling_nodes = dangling_nodes->next) {
      source = dangling_nodes->node;
      sum += source->prev_rank / g->node_count;
    }
    destination->rank = damping * sum + (1 - damping) / g->node_count;
  }
}

// Calculate the Euclidean distance from prev_rank to rank across all nodes
double prev_distance(Graph g) {
  NodeList nodes;
  Node n;
  double rank_diff, sum_squares = 0.0;

  for (nodes = g->nodes; nodes != NULL; nodes = nodes->next) {
    n = nodes->node;
    rank_diff = n->prev_rank - n->rank;
    sum_squares += rank_diff * rank_diff;
  }

  return sqrt(sum_squares);
}

void calculate(Graph g, int max_iterations, double damping, double tolerance) {
  calculate_start(g);

  while (max_iterations != 0) { // If negative one, allow to go without limit
    calculate_step(g, damping);
    if (prev_distance(g) < tolerance) {
      break;
    }
    max_iterations--;
  }
}

int node_compare(const void *v1, const void *v2) {
  double rank1, rank2, cmp;

  rank1 = (*(Node *)v1)->rank;
  rank2 = (*(Node *)v2)->rank;
  cmp = rank2 - rank1; // Decreasing order
  if (cmp < 0) return -1;
  if (cmp > 0) return 1;
  return 0;
}

void sort_and_normalize_ranks(Graph g, void (*callback)(VALUE, VALUE, double), VALUE callback_arg) {
  NodeList nodes;
  Node n;
  double sum = 0.0;
  unsigned long i;
  Node *tmp;

  i = g->node_count;
  tmp = malloc(g->node_count * sizeof(Node));
  for (nodes = g->nodes; nodes != NULL; nodes = nodes->next) {
    n = nodes->node;
    tmp[--i] = n;
    sum += n->rank;
  }

  qsort(tmp, g->node_count, sizeof(Node), node_compare);

  for (i = 0; i < g->node_count; i++) {
    n = tmp[i];
    callback(callback_arg, n->label, n->rank / sum);
  }

  free(tmp);
}

//////////////////////////////////////////////////////////////////////////////////////

static const rb_data_type_t graph_typed_data = {
  "PageRank/SparseNative/Graph",
  { 0, free_graph, },
  0, 0,
  RUBY_TYPED_FREE_IMMEDIATELY,
};

//////////////////////////////////////////////////////////////////////////////////////

void Init_sparse_native();
VALUE sparse_native_allocate(VALUE self);
VALUE sparse_native_add_edge(VALUE self, VALUE source, VALUE dest, VALUE weight);
VALUE sparse_native_calculate(VALUE self, VALUE max_iterations, VALUE damping, VALUE tolerance);
VALUE sorted_and_normalized_ranks(Graph g);
void rb_hash_dset(VALUE hash, VALUE key, double value);

//////////////////////////////////////////////////////////////////////////////////////

void Init_sparse_native() {
  VALUE PageRankModule, SparseNativeClass;

  PageRankModule = rb_const_get(rb_cObject, rb_intern("PageRank"));
  SparseNativeClass = rb_const_get(PageRankModule, rb_intern("SparseNative"));

  rb_define_alloc_func(SparseNativeClass, sparse_native_allocate);
  rb_define_private_method(SparseNativeClass, "_add_edge", sparse_native_add_edge, 3);
  rb_define_private_method(SparseNativeClass, "_calculate", sparse_native_calculate, 3);
}

VALUE sparse_native_allocate(VALUE self) {
  Graph g = malloc(GRAPH_SIZE);

  g->node_count = 0;
  g->nodes = NULL;
  g->dangling_nodes = NULL;
  g->node_lookup = rb_hash_tbl(rb_hash_new());

  return TypedData_Wrap_Struct(self, &graph_typed_data, g);
}

VALUE sparse_native_add_edge(VALUE self, VALUE source, VALUE dest, VALUE weight) {
  Graph g;

  TypedData_Get_Struct(self, GraphStruct, &graph_typed_data, g);
  add_edge_with_labels(g, source, dest, NUM2DBL(weight));
  return Qnil;
}

VALUE sparse_native_calculate(VALUE self, VALUE max_iterations, VALUE damping, VALUE tolerance) {
  Graph g;
  VALUE ranks;

  TypedData_Get_Struct(self, GraphStruct, &graph_typed_data, g);
  calculate(g, FIX2INT(max_iterations), NUM2DBL(damping), NUM2DBL(tolerance));

  ranks = rb_hash_new();
  sort_and_normalize_ranks(g, rb_hash_dset, ranks);
  return ranks;
}

void rb_hash_dset(VALUE hash, VALUE key, double value) {
  rb_hash_aset(hash, key, DBL2NUM(value));
}
