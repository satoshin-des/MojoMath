struct Matrix(Writable):
    var n: Int
    var m: Int
    var entry: List[List[Float64]]

    fn __init__(out self, n_: Int, m_: Int):
        self.entry = List[List[Float64]]()
        self.n = n_
        self.m = m_

        for _ in range(self.n):
            # var row = List[Float64](length=self.m, fill=0.0)
            self.entry.append(List[Float64](length=self.m, fill=0.0))
    
    fn write_to(self, mut writer: Some[Writer]):
        writer.write(self.entry)

    