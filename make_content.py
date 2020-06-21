template = """---
layout: layouts/index.html
"""
if __name__ == "__main__":
    for i in range(10**5):
        with open("page{}.md".format(i), "w") as f:
            pass
