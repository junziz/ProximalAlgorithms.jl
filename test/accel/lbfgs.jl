@testset "L-BFGS ($T)" for T in [Float32, Float64, Complex{Float32}, Complex{Float64}]

    using LinearAlgebra
    using ProximalAlgorithms: LBFGS, update!
    using RecursiveArrayTools: ArrayPartition, unpack

    Q = T[
            32.0000 13.1000 -4.9000 -3.0000  6.0000  2.2000  2.6000  3.4000 -1.9000 -7.5000;
            13.1000 18.3000 -5.3000 -9.5000  3.0000  2.1000  3.9000  3.0000 -3.6000 -4.4000;
            -4.9000 -5.3000  7.7000  2.1000 -0.4000 -3.4000 -0.8000 -3.0000  5.3000  5.5000;
            -3.0000 -9.5000  2.1000 20.1000  1.1000  0.8000  -12.4000 -2.5000  5.5000  2.1000;
            6.0000  3.0000 -0.4000  1.1000  3.8000  0.6000  0.5000  0.9000 -0.4000 -2.0000;
            2.2000  2.1000 -3.4000  0.8000  0.6000  7.8000  2.9000 -1.3000 -4.3000 -5.1000;
            2.6000  3.9000 -0.8000  -12.4000  0.5000  2.9000 14.5000  1.7000 -4.9000  1.2000;
            3.4000  3.0000 -3.0000 -2.5000  0.9000 -1.3000  1.7000  6.6000 -0.8000  2.7000;
            -1.9000 -3.6000  5.3000  5.5000 -0.4000 -4.3000 -4.9000 -0.8000  7.9000  5.7000;
            -7.5000 -4.4000  5.5000  2.1000 -2.0000 -5.1000  1.2000  2.7000  5.7000 16.1000;
    ]

    q = T[2.9000, 0.8000, 1.3000, -1.1000, -0.5000, -0.3000, 1.0000, -0.3000, 0.7000, -2.1000]

    xs = [
            T[1.0, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09],
            T[0.09, 1.0, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08],
            T[0.08, 0.09, 1.0, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07],
            T[0.07, 0.08, 0.09, 1.0, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06],
            T[0.06, 0.07, 0.08, 0.09, 1.0, 0.01, 0.02, 0.03, 0.04, 0.05]
    ]

    dirs_ref = [
        T[
            -3.476000000000000e+01,
            -1.367700000000000e+01,
            2.961000000000000e+00,
            3.756000000000000e+00,
            -5.618000000000001e+00,
            -1.571000000000000e+00,
            -4.121000000000000e+00,
            -3.709000000000000e+00,
            4.010000000000000e-01,
            7.639999999999999e+00,
        ],
        T[
            -6.861170733797231e-01,
            -1.661270665201917e+00,
            2.217225828759783e-01,
            5.615134140894827e-01,
            -1.922426760799171e-01,
            -8.961101045874649e-02,
            -3.044802963260585e-01,
            -1.996235459345302e-01,
            1.267604425710271e-01,
            3.360845247013288e-01,
        ],
        T[
            -1.621334774299757e-01,
            2.870743130038511e-01,
            -5.485761164147891e-01,
            9.992734938824949e-02,
            -1.332550298134261e-02,
            5.326252573648003e-02,
            -6.299408068289100e-02,
            1.525398352758626e-02,
            -7.776943954825602e-02,
            -2.335884953507600e-02,
        ],
        T[
            -2.008976150849174e-01,
            2.237224648542354e-01,
            4.811889625788801e-02,
            -6.855884193567087e-01,
            -2.729265954345345e-02,
            3.651730112313705e-02,
            6.325330777317102e-02,
            2.871281112230844e-02,
            -1.285590864125103e-01,
            -3.204963735369062e-03,
        ],
        T[
            -2.317011191832649e-01,
            2.980080835636926e-02,
            -1.267017945785352e-01,
            4.328230970765587e-02,
            -2.437461022925742e-01,
            1.349716200511426e-02,
            -7.155992987801297e-04,
            -3.513449694839536e-03,
            -5.603489763638488e-02,
            5.612114259243499e-02,
        ]
    ]

    @testset "Arrays" begin
        mem = 3
        x = zeros(T, 10)
        H = LBFGS(x, mem)
        dir = zeros(T, 10)
        for i = 1:5
            x = xs[i]
            grad = Q*x + q
            update!(H, x, grad)
            mul!(dir, H, -grad)
            @test dir ≈ dirs_ref[i]
        end
    end

    @testset "ArrayPartition" begin
        mem = 3
        x = ArrayPartition(zeros(T, 10), zeros(T, 10))
        H = LBFGS(x, mem)
        dir = ArrayPartition(zeros(T, 10), zeros(T, 10))
        for i = 1:5
            x = ArrayPartition(xs[i], xs[i])
            temp = Q*unpack(x, 1) + q
            grad = ArrayPartition(temp, temp)
            update!(H, x, grad)
            mul!(dir, H, -grad)
            @test unpack(dir, 1) ≈ dirs_ref[i]
            @test unpack(dir, 2) ≈ dirs_ref[i]
        end
    end
end