include("../src/UNSflow.jl")

using UNSflow


function fgfromrhoGauss(rho::Float64)
    f = sqrt(2./pi)*exp(-rho^2/2.)
    g = erf(rho/sqrt(2.)) - rho*f
    return f, g
end

function fgfromrhoLeonard(rho::Float64)
    f = 7.5/(rho^2 + 1.)^3.5
    g = (rho^3*(rho^2 + 2.5))/(rho^2 + 1.)^2.5
    return f, g
end

function mutual_ind(vorts::Vector{ThreeDVort})
      for i = 1:length(vorts)
          for j = i+1:length(vorts)
            rvec = vorts[i].x - vorts[j].x
#              dx = vorts[i].x[1] - vorts[j].x[1]
#              dy = vorts[i].x[2] - vorts[j].x[2]
#              dz = vorts[i].x[3] - vorts[j].x[3]
              #source - tar

            r = norm(rvec)
              rhoi = r/vorts[i].vc
              rhoj = r/vorts[j].vc

            f, g = fgfromrhoLeonard(rhoi)

            vorts[j].v[:] -= -g*cross(rvec,vorts[i].s)/(4.*pi*r^3)

              vorts[j].ds[:] += (-g*cross(vorts[j].s, vorts[i].s)/rhoi^3 +
            ((3*g/rhoi^3 - f)*dot(vorts[j].s, rvec)*cross(rvec,vorts[i].s))/r^2)/(4*pi*vorts[i].vc^3)


            f, g = fgfromrhoLeonard(rhoj)
            vorts[i].v[:] += -g*cross(rvec,vorts[j].s)/(4.*pi*r^3)

            vorts[i].ds[:] += (-g*cross(vorts[i].s, vorts[j].s)/rhoj^3 +
                ((3*g/rhoj^3 - f)*dot(vorts[i].s, rvec)*cross(rvec,vorts[j].s))/r^2)/(4*pi*vorts[j].vc^3)



          end
      end
      return vorts
end

function dovort()
    nvort = 250
vorts = ThreeDVort[]
for i = 1:nvort/5
        for j = 1:5
            x = [0.1*real(j); real(i)*0.05; 0.0]
    s = [0.0; 0.002; 0.0]
    vcore = 0.02
    v = [0.0; 0.0; 0.0]
    ds = [0.0; 0.0; 0.0]
    push!(vorts, ThreeDVort(x, s, vcore, v, ds))
end
    end

ntime = 100
dt = 0.015

@time for i =1:ntime
    for j = 1:nvort
        vorts[j].v[:] = 0
        vorts[j].ds[:] = 0
    end
    mutual_ind(vorts)
    for j = 1:nvort
        vorts[j].x[:] += vorts[j].v[:]*dt
        vorts[j].s[:] += vorts[j].ds[:]*dt
    end
end

end

