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
        writer.write(self.entry)

    fn at(self, i: Int, j: Int) raises -> Float64:
        if (i < 0) or (i >= self.n):
            raise Error("index is out-of-range")
        elif (j < 0) or (j >= self.m):
            raise Error("index is out-of-range")
        else:
            return self.entry[i][j]
    
    fn set_random(mut self, min: Float64 = 0.0, max: Float64 = 1.0):
        for i in range(self.n):
            for j in range(self.m):
                self.entry[i][j] = random_float64() * (max - min) + min

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