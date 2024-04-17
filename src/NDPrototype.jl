module NDPrototype
using Graphs
using OrderedCollections
using Unrolled

using ArgCheck: @argcheck
using PreallocationTools: LazyBufferCache

include("utils.jl")
include("edge_coloring.jl")
include("component_functions.jl")
include("network_structure.jl")
include("construction.jl")
include("coreloop.jl")

end
