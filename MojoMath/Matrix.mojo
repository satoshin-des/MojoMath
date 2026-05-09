from std.random import random_float64

struct Matrix(Writable):
    var n: Int
    var m: Int
    var entry: List[List[Float64]]

    fn __init__(out self, n_: Int, m_: Int):
        self.entry = List[List[Float64]]()
        self.n = n_
        self.m = m_

        for _ in range(self.n):
            self.entry.append(List[Float64](length=self.m, fill=0.0))
    
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
            Flase if is non-zero-matrix.
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
