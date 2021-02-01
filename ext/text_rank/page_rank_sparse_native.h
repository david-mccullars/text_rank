#ifndef PAGE_RANK_SPARSE_NATIVE_H
#define PAGE_RANK_SPARSE_NATIVE_H

#include <ruby.h>

struct NodeListStruct;
typedef struct NodeListStruct* NodeList;

typedef struct NodeListStruct {
  struct NodeStruct *node;
  struct NodeListStruct *next;
} NodeListStruct;

//////////////////////////////////////////////////////////////////////////////////////

struct EdgeListStruct;
typedef struct EdgeListStruct* EdgeList;

typedef struct EdgeListStruct {
  struct EdgeStruct *edge;
  struct EdgeListStruct *next;
} EdgeListStruct;

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

//////////////////////////////////////////////////////////////////////////////////////

struct EdgeStruct;
typedef struct EdgeStruct* Edge;

typedef struct EdgeStruct {
  Node source;
  double weight;
} EdgeStruct;

//////////////////////////////////////////////////////////////////////////////////////

struct GraphStruct;
typedef struct GraphStruct* Graph;

typedef struct GraphStruct {
  unsigned long node_count;
  NodeList nodes;
  NodeList dangling_nodes;
  st_table *node_lookup;
} GraphStruct;

//////////////////////////////////////////////////////////////////////////////////////

void free_graph(void *data);
void free_node(Node n);
void free_node_list(NodeList nodes, void (*free_item)(Node));
void free_edge(Edge e);
void free_edge_list(EdgeList edges, void (*free_item)(Edge));

//////////////////////////////////////////////////////////////////////////////////////

Node add_node(Graph g, VALUE label);
Node add_dangling_node(Graph g, Node n);
Edge add_edge(Node source, Node destination, double weight);
Edge add_edge_with_labels(Graph g, VALUE source_label, VALUE dest_label, double weight);
Node lookup_node(Graph g, VALUE label);

//////////////////////////////////////////////////////////////////////////////////////

void calculate_start(Graph g);
void calculate_step(Graph g, double damping);
double prev_distance(Graph g);
void calculate(Graph g, int max_iterations, double damping, double tolerance);
int node_compare(const void *v1, const void *v2);
void sort_and_normalize_ranks(Graph g, void (*callback)(VALUE, VALUE, double), VALUE callback_arg);

//////////////////////////////////////////////////////////////////////////////////////

void Init_sparse_native();
VALUE sparse_native_allocate(VALUE self);
VALUE sparse_native_add_edge(VALUE self, VALUE source, VALUE dest, VALUE weight);
VALUE sparse_native_calculate(VALUE self, VALUE max_iterations, VALUE damping, VALUE tolerance);
VALUE sorted_and_normalized_ranks(Graph g);
void rb_hash_dset(VALUE hash, VALUE key, double value);

#endif
