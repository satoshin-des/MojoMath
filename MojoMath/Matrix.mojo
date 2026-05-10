from std.random import random_float64

struct Matrix[type: DType](Writable, Movable):
    var n: Int
    var m: Int
    var entry: List[List[Scalar[Self.type]]]

    fn __init__(out self, n_: Int, m_: Int):
        self.entry = List[List[Scalar[Self.type]]]()
        self.n = n_
        self.m = m_

        for _ in range(self.n):
            self.entry.append(List[Scalar[Self.type]](length=self.m, fill=0))
    
    fn __add__(self, other: Self) raises -> Self:
        if (self.n != other.n) or (self.m != other.m):
            raise Error("Addition of other size matrices is not defined.")
        
        var mat = Self(self.n, self.m)
        for i in range(self.n):
            for j in range(self.m):
                mat.entry[i][j] = self.entry[i][j] + other.entry[i][j]
        return mat^

    fn __sub__(self, other: Self) raises -> Self:
        if (self.n != other.n) or (self.m != other.m):
            raise Error("Addition of other size matrices is not defined.")
        
        var mat = Self(self.n, self.m)
        for i in range(self.n):
            for j in range(self.m):
                mat.entry[i][j] = self.entry[i][j] - other.entry[i][j]
        return mat^
    
    fn __mul__(self, other: Self) raises -> Self:
        if self.m != other.n:
            raise Error("Multiplication is not defined")
        
        var mat = Self(self.n, self.m)
        for i in range(self.n):
            for j in range(self.m):
                mat.entry[i][j] = 0
                for k in range(self.m):
                    mat.entry[i][j] += self.entry[i][k] * other.entry[k][j]
        return mat^
    
    fn __eq__(self, other: Self) -> Bool:
        if (self.n != other.n) or (self.m != other.m):
            return False

        for i in range(self.n):
            for j in range(self.m):
                if abs(Float64(self.entry[i][j] - other.entry[i][j])) > 1e-6:
                    return False
        return True
    
    fn __ne__(self, other: Self) -> Bool:
        if (self.n != other.n) or (self.m != other.m):
            return True

        for i in range(self.n):
            for j in range(self.m):
                if abs(Float64(self.entry[i][j] - other.entry[i][j])) > 1e-6:
                    return True
        return False
    
    @staticmethod
    fn Vector(n: Int) -> Self:
        var v = Self(n, 1)
        return v^

    fn inner_product(self, other: Self) raises -> Scalar[Self.type]:
        """Inner product of two vectors.
        Args:
            other: Matrix Vector.
        
        Returns:
            Inner product.
        """
        if ((self.n != 1) and (self.m != 1)) or ((other.n != 1) and (other.m != 1)):
            raise Error("Inner product is only defined Matrix class is Vector-like")

        var s: Scalar[Self.type] = 0

        if self.n == 1:
            if other.n == 1:
                if self.m != other.m:
                    raise Error("Inner product of ther size vectors is not defined")
                for i in range(self.m):
                    s += self.entry[0][i] * other.entry[0][i]
            else:
                if self.m != other.n:
                    raise Error("Inner product of ther size vectors is not defined")
                for i in range(self.m):
                    s += self.entry[0][i] * other.entry[i][0]
        else:
            if other.n == 1:
                if self.n != other.m:
                    raise Error("Inner product of ther size vectors is not defined")
                for i in range(self.n):
                    s += self.entry[i][0] * other.entry[0][i]
            else:
                if self.n != other.n:
                    raise Error("Inner product of ther size vectors is not defined")
                for i in range(self.n):
                    s += self.entry[i][0] * other.entry[i][0]
        return s
    
    fn hadamard_product(self, other: Self) raises -> Self:
        """Hadamard product of two matrices.
        """
        if (self.n != other.n) or (self.m != other.m):
            raise Error("Hadamard product of other sized matrices is not defined.")
        
        var m: Self = Self(self.n, self.m)

        for i in range(self.n):
            for j in range(self.m):
                m.entry[i][j] = self.entry[i][j] * other.entry[i][j]
        
        return m^

    fn __copyinit__(mut self, existing: Self):
        self.entry = existing.entry.copy()
        self.m = existing.m
        self.n = existing.n

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(String(self.entry).replace("],", "],\n"))

    fn at(self, i: Int, j: Int) raises -> Scalar[Self.type]:
        if (i < 0) or (i >= self.n):
            raise Error("index is out-of-range")
        elif (j < 0) or (j >= self.m):
            raise Error("index is out-of-range")
        else:
            return self.entry[i][j]
    
    fn set_random(mut self, min: Scalar[Self.type] = 0, max: Scalar[Self.type] = 1) raises:
        """Set all entries of matrix to random.
        Args:
            min: T lower bound of random.
            max: T upper bound of random.
        """
        for i in range(self.n):
            for j in range(self.m):
                self.entry[i][j] = Scalar[Self.type](random_float64() * Float64(max - min) + Float64(min))
    
    fn set_identity(mut self):
        """Set matrix to identity matrix.
        """
        for i in range(self.n):
            for j in range(self.m):
                if i == j:
                    self.entry[i][j] = 1
                else:
                    self.entry[i][j] = 0
    
    fn set_as[uype: DType](mut self, mat: Matrix[uype]) raises:
        if (self.n != mat.n) or (self.m != mat.m):
            raise Error("matrix sizes is defferent.")

        for i in range(self.n):
            for j in range(self.m):
                self.entry[i][j] = Scalar[Self.type](mat.entry[i][j])
    
    fn fill(mut self, a: Scalar[Self.type]):
        """Set all entries of matrix to ``a``.
        """
        for i in range(self.n):
            for j in range(self.m):
                self.entry[i][j] = a
    
    fn round_to_int(mut self):
        """Round all entries to integer.
        """
        for i in range(self.n):
            for j in range(self.m):
                self.entry[i][j] = round(self.entry[i][j])

    fn norm(self, p: Int = 2) raises -> Float64:
        """Compute Lp-norm of matrix.
        Args:
            p: Int "p" of Lp-norm.
        
        Returns:
            Lp-norm.
        """
        if p < 1:
            raise Error("\"p\" of the norm must be greater than or equal to 1")

        var s: Float64 = 0.0
        for i in range(self.n):
            for j in range(self.m):
                s += pow(abs(Float64(self.entry[i][j])), p)
        
        return pow(s, 1.0 / Float64(p))

    fn is_zero(self, err: Float64 = 1e-6) raises -> Bool:
        """Test the matrix is zero or non-zero.
        Args:
            err: Float64: error of zero-testing.
        
        Returns:
            True if is zero-matrix.
            False if is non-zero-matrix.
        """
        if err < 0:
            raise Error("error of zero-testing must be greater than or equal to 0")
        
        for i in range(self.n):
            for j in range(self.m):
                if abs(Float64(self.entry[i][j])) > err:
                    return False
        return True
    
    fn trace(self) -> Scalar[Self.type]:
        """Compute trace.
        """
        var s: Scalar[Self.type] = 0
        for i in range(min(self.n, self.m)):
            s += self.entry[i][i]
        return s

    fn sum(self) -> Scalar[Self.type]:
        """Compute summation of all entries in matrix.
        """
        var s: Scalar[Self.type] = 0
        for i in range(self.n):
            for j in range(self.m):
                s += self.entry[i][j]
        return s

    fn prod(self) -> Scalar[Self.type]:
        """Compute product of all entries in matrix.
        """
        var p: Scalar[Self.type] = 1
        for i in range(self.n):
            for j in range(self.m):
                p *= self.entry[i][j]
        return p

    fn mean(self) -> Float64:
        """Compute mean.
        """
        return Float64(self.sum()) / Float64(self.n * self.m)
    
    fn transpose(self) -> Self:
        """Compute tranpose of Matrix.
        """
        var mat = Self(self.m, self.n)
        for i in range(self.n):
            for j in range(self.m):
                mat.entry[j][i] = self.entry[i][j]
        return mat^

    fn det(self) -> Scalar[Self.type]:
        """Compute a determinant.
        """
        var a: List[List[Scalar[Self.type]]] = self.entry.copy()
        var r: Int = 0
        var m: Scalar[Self.type]
        var p: Int = 0
        var v: List[Scalar[Self.type]]
        for j in range(self.n):
            m = -1
            for i in range(j, self.n):
                if abs(a[i][j]) > m:
                    m = abs(a[i][j])
                    p = i
            if abs(Float64(a[p][j])) < 1e-6:
                return 0
            if p > j:
                v = a[j].copy()
                a[j] = a[p].copy()
                a[p] = v.copy()
                r += 1
            for i in range(j + 1, self.n):
                m = a[i][j] / a[j][j]
                for k in range(j, self.n):
                    a[i][k] -= m * a[j][k]
        
        var d: Scalar[Self.type] = 1
        if r & 1:
            d = -1
        for i in range(self.n):
            d *= a[i][i]
        return d

    fn pow(self, n: Int) raises -> Self:
        """Compute the power of matrix.
        Args:
            n: Int exponent of the power.
        
        Returns:
            An n-th power.
        """
        if n < 0:
            raise Error("Exponential must be greater than or equal to 0.")
        if self.n != self.m:
            raise Error("Power of non-square matrix is not defined")
        
        var res: Self = Self(self.n, self.n)
        res.set_identity()

        if n == 0:
            return res^

        var cur_n: Int = n
        var a: Self = Self(self.n, self.n)
        a.entry = self.entry.copy()

        while cur_n > 0:
            if cur_n & 1:
                res = res * a
            a = a * a
            cur_n = cur_n >> 1
        return res^

    fn lu(self) raises -> Tuple[Matrix[DType.float64], Matrix[DType.float64]]:
        """LU-decomposite matrix.
        Returns:
            Tuple of the lower triangular matrix and upper triangular matrix.
        """
        if self.n != self.m:
            raise Error("Augment for ``lu`` must be square matrix")
        var U = Matrix[DType.float64](self.n, self.n)
        var L = Matrix[DType.float64](self.n, self.n)
        L.set_identity()
        U.set_as(self)

        for k in range(self.n - 1):
            for j in range(k + 1, self.n):
                L.entry[j][k] = U.entry[j][k] / U.entry[k][k]
                for i in range(k, self.n):
                    U.entry[j][i] -= L.entry[j][k] * U.entry[k][i]
        
        return (L^, U^)
