# %%
import matplotlib.pyplot as plt
import numpy

# %%
generic = "generic.dat"
ortho = "ortho.dat"
dataName = {
    "arrayLatestPerf": "arrayPbcPerfInline",
    # "arrayTool": "arrayPbcPerfInlineTool",
    "array": "arrayPbcPerf",
    "arrayLatest": "arrayPbcInline",
    "master": "master080224",
    "masterPerf": "master080224Perf",
    "optimize-pbc": "optimize-pbc",
}


# %%

dataGeneric = {}

for name in dataName.keys():
    dataGeneric[name] = numpy.loadtxt(dataName[name] + generic)

dataOrtho = {}
for name in dataName.keys():
    dataOrtho[name] = numpy.loadtxt(dataName[name] + ortho)
xnames = numpy.asarray(dataOrtho["master"][:, 0], dtype=int)


dataDistGeneric = {}
for name in dataName.keys():
    dataDistGeneric[name] = numpy.loadtxt(dataName[name] + "_dist_" + generic)
dataDistOrtho = {}
for name in dataName.keys():
    dataDistOrtho[name] = numpy.loadtxt(dataName[name] + "_dist_" + ortho)

dataGeneric.keys()

# %%
def myplot(
    dataList: dict,
    dataList2: dict,
    n1: str = "master",
    n2: str = "arrayLatest",
    log=False,
    labels=False,
    ax=None,
):
    if ax is None:
      _, ax = plt.subplots()
    x = numpy.arange(dataList[n1].shape[0])
    width = 0.2  # the width of the bars
    multiplier = 0
    print("| what: | "+"(ns) | ".join([str(xn) for xn in xnames]+[""]))
    print("| --- | "+" | ".join(["---" for xn in xnames])+" |")
    for name in [n1, n2]:
        offset = width * multiplier
        rects = ax.bar(
            x + offset,
            dataList[name][:, 1],
            width,
            label=name + "[ortho]",
            align="edge",
        )
        if labels:
            ax.bar_label(rects, padding=3)
        multiplier += 1
        print(f"| {name}[ortho]: | "+" | ".join([str(int(xn)) for xn in dataList[name][:, 1]])+" |")
    for name in [n1, n2]:
        offset = width * multiplier
        rects = ax.bar(
            x + offset, dataList2[name][:, 1], width, label=name + "[generic]", align="edge"
        )
        if labels:
            ax.bar_label(rects, padding=3 * multiplier, fmt="%0.1g")
        multiplier += 1
        print(f"| {name}[generic]:| "+" | ".join([str(int(xn)) for xn in dataList2[name][:, 1]])+" |")
    if log:
        ax.set_yscale("log")
    ax.legend()
    ax.set_ylabel(("log " if log else "") +r"time per 10000 apply ($n s$)")
    ax.set_xticks(x + width * 2, xnames)
    return ax


myplot(dataOrtho, dataGeneric, log=True)


# %%
def myplotPercent(
    dataList: dict,
    dataList2: dict,
    n1: str = "master",
    n2: str = "arrayLatest",
    log=False,
    labels=False,
    ax=None,
):
    if ax is None:
      _, ax = plt.subplots()
    x = numpy.arange(dataList[n1].shape[0])
    width = 0.2  # the width of the bars
    multiplier = 0
    names = ["[ortho]", "[generic]"]
    for i, mydict in enumerate([dataList, dataList2]):
        offset = width * multiplier

        # t = 100*(mydict[n1][:, 1] - mydict[n2][:, 1])/(mydict[n1][:, 1] + mydict[n2][:, 1])
        t = 100 * (mydict[n1][:, 1] - mydict[n2][:, 1]) / (mydict[n1][:, 1])
        print(t)
        rects = ax.bar(
            x + offset,
            t,
            width,
            label=names[i],
            align="edge",
        )
        if labels:
            ax.bar_label(rects, padding=3)
        multiplier += 1
    if log:
        ax.set_yscale("log")
    ax.legend()
    ax.set_ylabel(f"(t({n1})-t({n2}))/t({n1})*100")
    ax.set_xticks(x + width, xnames)
    return ax



# %%
myplotPercent(dataOrtho, dataGeneric, n2="arrayLatestPerf")
myplotPercent(dataOrtho, dataGeneric)
# %%
myplot(dataDistOrtho, dataDistGeneric, n2="masterPerf")
myplot(dataOrtho, dataGeneric, n2="masterPerf")
# %%
myplotPercent(dataDistOrtho, dataDistGeneric, n2="masterPerf")
myplotPercent(dataOrtho, dataGeneric, n2="masterPerf")
# %%
myplotPercent(dataOrtho, dataGeneric, n1="arrayLatest", n2="arrayLatestPerf")
myplotPercent(dataOrtho, dataGeneric, n1="arrayLatest", n2="arrayLatestPerf")
# %%
_, axes =  plt.subplots(1,2)
myplot(dataOrtho, dataGeneric, log=True,ax=axes[0])
myplot(dataOrtho, dataGeneric, log=False,ax=axes[1])
#%%

myplot(dataOrtho, dataGeneric, log=True)
myplotPercent(dataOrtho, dataGeneric, log=False)

#%%
ax=myplot(dataDistOrtho, dataDistGeneric, log=True)
ax.set_ylabel(("log " +r"time per 99999 distance ($n s$)"))
myplotPercent(dataDistOrtho, dataDistGeneric, log=False)

#%%

myplot(dataOrtho, dataGeneric, log=True,n2="optimize-pbc")
myplotPercent(dataOrtho, dataGeneric, log=False,n2="optimize-pbc", labels=True)
