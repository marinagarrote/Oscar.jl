# standard packages
using Markdown
using Pkg
using Random
using RandomExtensions
using Test

# our packages
import AbstractAlgebra
import GAP
import Hecke
import Nemo
import Polymake
import Singular

# import stuff from Base for which we want to provide extra methods
import Base:
    *,
    ^,
    ==,
    convert,
    exponent,
    getindex,
    intersect,
    isfinite,
    length,
    mod,
    one,
    parent,
    print,
    show,
    values,
    Vector,
    zero

import AbstractAlgebra:
    @attributes,
    @show_name,
    @show_special,
    addeq!,
    base_ring,
    canonical_unit,
    codomain,
    degree,
    dim,
    domain,
    elem_type,
    evaluate,
    expressify,
    Field,
    FieldElem,
    force_coerce,
    force_op,
    gen,
    Generic,
    Generic.finish,
    Generic.MPolyBuildCtx,
    Generic.MPolyCoeffs,
    Generic.MPolyExponentVectors,
    Generic.push_term!,
    gens,
    get_attribute,
    get_attribute!,
    Ideal,
    map,
    MatElem,
    matrix,
    MatSpace,
    MPolyElem,
    MPolyRing,
    ngens,
    nvars,
    ordering,
    parent_type,
    PolyElem,
    PolynomialRing,
    PolyRing,
    Ring,
    RingElem,
    RingElement,
    set_attribute!,
    SetMap,
    symbols,
    total_degree

import GAP:
    @gapattribute,
    @gapwrap,
    GapInt,
    GapObj

import Nemo:
    bell,
    binomial,
    denominator,
    divexact,
    divides,
    divisor_sigma,
    euler_phi,
    factorial,
    fibonacci,
    fits,
    FlintIntegerRing,
    FlintRationalField,
    fmpq,
    fmpq_mat,
    fmpz,
    fmpz_mat,
    fq_nmod,
    FractionField,
    height,
    isprime,
    isprobable_prime,
    isqrtrem,
    issquare,
    isunit,
    iszero,
    jacobi_symbol,
    MatrixSpace,
    moebius_mu,
    number_of_partitions,
    numerator,
    primorial,
    QQ,
    rising_factorial,
    root,
    unit,
    ZZ

exclude = [:Nemo, :AbstractAlgebra, :Rational, :change_uniformizer, :genus_symbol, :data,
    :isdefintie, :narrow_class_group]

for i in names(Hecke)
  i in exclude && continue
  eval(Meta.parse("import Hecke." * string(i)))
  eval(Expr(:export, i))
end

import Hecke:
    _rational_canonical_form_setup,
    @req,
    abelian_group,
    automorphism_group,
    center,
    cokernel,
    compose,
    defining_polynomial,
    derived_series,
    det,
    direct_product,
    elements,
    field_extension,
    FinField,
    FinFieldElem,
    FqNmodFiniteField,
    free_abelian_group,
    gram_matrix,
    haspreimage,
    hom,
    id_hom,
    image,
    index,
    IntegerUnion,
    inv!,
    isabelian,
    isbijective,
    ischaracteristic,
    isconjugate,
    iscyclic,
    isinjective,
    isinvertible,
    isisomorphic,
    isnormal,
    isprimitive,
    isregular,
    issimple,
    issubgroup,
    issurjective,
    kernel,
    Map,
    MapHeader,
    math_html,
    mul,
    mul!,
    multiplicative_jordan_decomposition,
    normal_closure,
    nrows,
    one!,
    order,
    perm,
    preimage,
    primitive_element,
    quo,
    radical,
    refine_for_jordan,
    representative,
    small_group,
    sub,
    subgroups,
    tr,
    trace