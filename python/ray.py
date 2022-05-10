class Ray:
    def __init__(self, orig, dir):
        self.orig = orig
        self.dir = dir

    def at(self, t):
        return self.orig + self.dir * t
