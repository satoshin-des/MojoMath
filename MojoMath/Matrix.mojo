from std.random import random_float64

struct Matrix(Writable, Movable):
    var n: Int
    var m: Int
    var entry: List[List[Float64]]

    fn __init__(out self, n_: Int, m_: Int):
        self.entry = List[List[Float64]]()
        self.n = n_
        self.m = m_

        for _ in range(self.n):
            self.entry.append(List[Float64](length=self.m, fill=0.0))
    
    fn __add__(self, other: Matrix) raises -> Matrix:
        if (self.n != other.n) or (self.m != other.m):
            raise Error("Addition of other size matrices is not defined.")
        
        var mat = Matrix(self.n, self.m)
        for i in range(self.n):
            for j in range(self.m):
                mat.entry[i][j] = self.entry[i][j] + other.entry[i][j]
        return mat^

    fn __sub__(self, other: Matrix) raises -> Matrix:
        if (self.n != other.n) or (self.m != other.m):
            raise Error("Addition of other size matrices is not defined.")
        
        var mat = Matrix(self.n, self.m)
        for i in range(self.n):
            for j in range(self.m):
                mat.entry[i][j] = self.entry[i][j] - other.entry[i][j]
        return mat^
    
    fn __mul__(self, other: Matrix) raises -> Matrix:
        if self.m != other.n:
            raise Error("Multiplication is not defined")
        
        var mat = Matrix(self.n, self.m)
        for i in range(self.n):
            for j in range(self.m):
                mat.entry[i][j] = 0.0
                for k in range(self.m):
                    mat.entry[i][j] += self.entry[i][k] * other.entry[k][j]
        return mat^
    
    fn __eq__(self, other: Matrix) -> Bool:
        if (self.n != other.n) or (self.m != other.m):
            return False

        for i in range(self.n):
            for j in range(self.m):
                if abs(self.entry[i][j] - other.entry[i][j]) > 1e-6:
                    return False
        return True
    
    fn __ne__(self, other: Matrix) -> Bool:
        if (self.n != other.n) or (self.m != other.m):
            return True

        for i in range(self.n):
            for j in range(self.m):
                if abs(self.entry[i][j] - other.entry[i][j]) > 1e-6:
                    return True
        return False
    
    @staticmethod
    fn Vector(n: Int) -> Matrix:
        var v = Matrix(n, 1)
        return v^

    fn inner_product(self, other: Matrix) raises -> Float64:
        """Inner product of two vectors.
        Args:
            other: Matrix Vector.
        
        Returns:
            Inner product.
        """
        if ((self.n != 1) and (self.m != 1)) or ((other.n != 1) and (other.m != 1)):
            raise Error("Inner product is only defined Matrix class is Vector-like")

        var s: Float64 = 0.0

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

    fn __copyinit__(mut self, existing: Self):
        self.entry = existing.entry.copy()
        self.m = existing.m
        self.n = existing.n

    fn write_to(self, mut writer: Some[Writer]):
        writer.write(String(self.entry).replace("],", "],\n"))

    fn at(self, i: Int, j: Int) raises -> Float64:
        if (i < 0) or (i >= self.n):
            raise Error("index is out-of-range")
        elif (j < 0) or (j >= self.m):
            raise Error("index is out-of-range")
        else:
            return self.entry[i][j]
    
    fn set_random(mut self, min: Float64 = 0.0, max: Float64 = 1.0):
        """Set all entries of matrix to random.
        Args:
            min: Float64 lower bound of random.
            max: Float64 upper bound of random.
        """
        for i in range(self.n):
            for j in range(self.m):
                self.entry[i][j] = random_float64() * (max - min) + min
    
    fn set_identity(mut self):
        """Set matrix to identity matrix.
        """
        for i in range(self.n):
            for j in range(self.m):
                if i == j:
                    self.entry[i][j] = 1.0
                else:
                    self.entry[i][j] = 0.0
    
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
                s += pow(abs(self.entry[i][j]), p)
        
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
                if abs(self.entry[i][j]) > err:
                    return False
        return True
    
    fn trace(self) -> Float64:
        """Compute trace.
        """
        var s: Float64 = 0.0
        for i in range(min(self.n, self.m)):
            s += self.entry[i][i]
        return s

    fn sum(self) -> Float64:
        """Compute summation of all entries in matrix.
        """
        var s: Float64 = 0.0
        for i in range(self.n):
            for j in range(self.m):
                s += self.entry[i][j]
        return s

    fn prod(self) -> Float64:
        """Compute product of all entries in matrix.
        """
        var p: Float64 = 1.0
        for i in range(self.n):
            for j in range(self.m):
                p *= self.entry[i][j]
        return p

    fn mean(self) -> Float64:
        """Compute mean.
        """
        return self.sum() / Float64(self.n * self.m)
    
    fn transpose(self) -> Matrix:
        """Compute tranpose of Matrix.
        """
        var mat = Matrix(self.m, self.n)
        for i in range(self.n):
            for j in range(self.m):
                mat.entry[j][i] = self.entry[i][j]
        return mat^

    fn det(self) -> Float64:
        """Compute a determinant.
        """
        var a: List[List[Float64]] = self.entry.copy()
        var r: Int = 0
        var m: Float64
        var p: Int = 0
        var v: List[Float64]
        for j in range(self.n):
            m = -1
            for i in range(j, self.n):
                if abs(a[i][j]) > m:
                    m = abs(a[i][j])
                    p = i
            if abs(a[p][j]) < 1e-6:
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
        
        var d: Float64 = 1
        if r & 1:
            d = -1
        for i in range(self.n):
            d *= a[i][i]
        return d

