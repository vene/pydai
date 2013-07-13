from libcpp.vector cimport vector

cdef extern from "dai/var.h" namespace "dai":
    cdef cppclass Var:
        Var()
        Var(int, int)

cdef extern from "dai/varset.h" namespace "dai":
    cdef cppclass VarSet:
        VarSet()
        VarSet(Var&)
        VarSet(Var&, Var&)
        VarSet& insert(Var)

cdef extern from "dai/factor.h" namespace "dai":
    cdef cppclass TFactor[T]:
        TFactor()
        TFactor(Var&)
        TFactor(VarSet&)
        void set(int, T)
        TFactor[T] marginal(VarSet&, bool)
        TFactor[T]& multiply "operator*=" (TFactor[T]&)
        T get (int)
    
    ctypedef TFactor[double] Factor

cdef extern from "dai/factorgraph.h" namespace "dai":
    cdef cppclass FactorGraph:
        FactorGraph()
        FactorGraph(vector[Factor]&)
        int nrVars()
        int nrFactors()
        Factor& factor(int)
