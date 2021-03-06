

"""
    helmholtz_equation(Args...; Kwargs...)

Solve Helmholz equation using Greens function.

# Arguments
- `ψ::QuantumState`  :  Initial quess
- `H::Union{HamiltonOperator, HamiltonOperatorMagneticField}`  : Hamilton
    associated with Helmholtz equation that is solved

# Keywords
- `tn=96`      : number of t-integration points
- `tmax=300`   : maximum value for t-integration
- `showprogress=false`   :  display progress bar
"""
function helmholtz_equation(ψ::QuantumState, H::HamiltonOperator;
                            tn=96, tmax=300, showprogress=false)
    normalize!(ψ)
    E = real(bracket(ψ,H,ψ))
    @info "E=$E"
    k  = sqrt( -2(austrip(E)) )
    ct = optimal_coulomb_tranformation(H.elementgrid, tn; k=k);
    ϕ = H.T.m*H.V*1u"ħ_au^-2" * ψ
    ϕ = poisson_equation(ϕ, ct; tmax=tmax, showprogress=showprogress);
    normalize!(ϕ)
    return ϕ
end

function helmholtz_equation!(ψ::QuantumState, H::HamiltonOperator;
                            tn=96, tmax=300, showprogress=false)
    normalize!(ψ)
    E = real(bracket(ψ,H,ψ))
    @info "E=$E"
    k  = sqrt( -2(austrip(E)) )
    ct = optimal_coulomb_tranformation(H.elementgrid, tn; k=k);
    ϕ = H.T.m*H.V*1u"ħ_au^-2" * ψ
    ψ .= poisson_equation(ϕ, ct; tmax=tmax, showprogress=showprogress);
    normalize!(ψ)
    return ψ
end


function helmholtz_equation(ψ::QuantumState, H::HamiltonOperatorMagneticField;
                            tn=96, tmax=300, showprogress=false)
    normalize!(ψ)
    E = real(bracket(ψ,H,ψ))
    @info "E=$E"
    k  = sqrt( -2(austrip(E)) )
    ct = optimal_coulomb_tranformation(H.elementgrid, tn; k=k);
    p = momentum_operator(H.T)
    #TODO These could run parallel
    ϕ = H.T.m*H.V*1u"ħ_au^-2" * ψ + (H.q^2*u"ħ_au^-2")*(H.A⋅H.A)*ψ
    ϕ += (H.q*u"ħ_au^-2")*(H.A⋅p + p⋅H.A) * ψ
    ϕ = poisson_equation(ϕ, ct; tmax=tmax, showprogress=showprogress);
    normalize!(ϕ)
    return ϕ
end
