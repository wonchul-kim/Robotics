import math
from math import sqrt
import numbers

def zeroes(height, width):
        """
        Creates a matrix of zeroes.
        """
        g = [[0.0 for _ in range(width)] for __ in range(height)]
        return Matrix(g)

def identity(n):
        """
        Creates a n x n identity matrix.
        """
        I = zeroes(n, n)
        for i in range(n):
            I.g[i][i] = 1.0
        return I

class Matrix(object):

    # Constructor
    def __init__(self, grid):
        self.g = grid
        self.h = len(grid)
        self.w = len(grid[0])

    #
    # Primary matrix math methods
    #############################
 
    def determinant(self):
        """
        Calculates the determinant of a 1x1 or 2x2 matrix.
        """
        if not self.is_square():
            raise(ValueError, "Cannot calculate determinant of non-square matrix.")
        if self.h > 2:
            raise(NotImplementedError, "Calculating determinant not implemented for matrices largerer than 2x2.")
        
        # TODO - your code here
        if self.h == 1:
            determinant = self.grid[0][0]
        else:
            if self.g[0][0]*self.g[1][1] == self.g[0][1]*self.g[1][0]:
                raise ValueError('The matrix is not invertible')
            else:
                determinant = \
                (self.g[0][0]*self.g[1][1] - self.g[0][1]*self.g[1][0])

        return determinant
    
    def trace(self):
        """
        Calculates the trace of a matrix (sum of diagonal entries).
        """
        if not self.is_square():
            raise(ValueError, "Cannot calculate the trace of a non-square matrix.")

        # TODO - your code here
        ret = 0
        for i in range(self.h):
            for j in range(self.w):
                if i == j:
                    sum += self.g[i][j]

        return ret
    
    def inverse(self):
        """
        Calculates the inverse of a 1x1 or 2x2 Matrix.
        """
        if not self.is_square():
            raise(ValueError, "Non-square Matrix does not have an inverse.")
        if self.h > 2:
            raise(NotImplementedError, "inversion not implemented for matrices larger than 2x2.")

        # TODO - your code here
        det = self.determinant()
        
        if self.h == 1:
            inverse = 1/det
        else:
            inverse = 1/det*[[self.g[1][1], -self.g[0][1]], [-self.g[1][0], self.g[0][0]]]
        
        return inverse                 
                
    def T(self):
        """
        Returns a transposed copy of this Matrix.
        """
        # TODO - your code here
        t = []
        for c in range(self.w):
            row = []
            for r in range(self.h):
                row.append(self.g[r][c])
            t.append(row)
            
        return t
    
    def is_square(self):
        return self.h == self.w

    #
    # Begin Operator Overloading
    ############################
    def __getitem__(self,idx):
        """
        Defines the behavior of using square brackets [] on instances
        of this class.

        Example:

        > my_matrix = Matrix([ [1, 2], [3, 4] ])
        > my_matrix[0]
          [1, 2]

        > my_matrix[0][0]
          1
        """
        return self.g[idx]

    def __repr__(self):
        """
        Defines the behavior of calling print on an instance of this class.
        """
        s = ""
        for row in self.g:
            s += " ".join(["{} ".format(x) for x in row])
            s += "\n"
        return s

    def __add__(self,other):
        """
        Defines the behavior of the + operator
        """
        if self.h != other.h or self.w != other.w:
            raise(ValueError, "Matrices can only be added if the dimensions are the same") 
        #   
        # TODO - your code here
        #
        add = []
        for r in range(self.h):
            ret = []
            for c in range(self.w):
                ret.append(self.g[r][c] + other[r][c])
            add.append(ret)    
        return add

    def __neg__(self):
        """
        Defines the behavior of - operator (NOT subtraction)

        Example:

        > my_matrix = Matrix([ [1, 2], [3, 4] ])
        > negative  = -my_matrix
        > print(negative)
          -1.0  -2.0
          -3.0  -4.0
        """
        #   
        # TODO - your code here
        #
        matrixNeg = []
        for i in range(self.h):
            row = []
            for j in range(self.w):
                row.append(-1 * self[i][j] )
            matrixNeg.append(row)
        
        return Matrix(matrixNeg)

    def __sub__(self, other):
        """
        Defines the behavior of - operator (as subtraction)
        """
        #   
        # TODO - your code here
        #
        
        # Get dimensions of the Matrix 1 and the Matrix 2
        m_rows = self.h
        p_columns = other.w
        
        # empty list that will hold the product of AxB
        matrixMul = []
        
        for i in range(m_rows):
            row = []
            for j in range(p_columns):
                row.append(dot_product(get_row(self.g,i),get_column(other.g,j)))
            matrixMul.append(row)

        return Matrix(matrixMul)

    def __mul__(self, other):
        """
        Defines the behavior of * operator (matrix multiplication)
        """
        #   
        # TODO - your code here
        #

    def __rmul__(self, other):
        """
        Called when the thing on the left of the * is not a matrix.

        Example:

        > identity = Matrix([ [1,0], [0,1] ])
        > doubled  = 2 * identity
        > print(doubled)
          2.0  0.0
          0.0  2.0
        """
        if isinstance(other, numbers.Number):
            pass
            #   
            # TODO - your code here
            #
            matrixRmul = Matrix(self.g)
            for i in range(self.h):
                for j in range(self.w):
                    matrixRmul[i][j] = self.g[i][j] * other
                    
            return (matrixRmul)
