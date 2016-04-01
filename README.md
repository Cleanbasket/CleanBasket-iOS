# CLEANBASKET

```
Lead Developer : Cha Yongbin
```

### Code Style Guide
- Objective - C : NYTimes Objective-C Style Guide 
- Swift : Cleanbakset Swift Style Guide

### Commit Message Rule

- UI 개선 요소
``` 
- [Updated] Update icon ({icon Name})
- [Updated] Update UI Component ({Component Name})
```
- Login 수정
```
// 함수 하나 Refactoring
- [Refactoring] Refactoring Function {Function Name}
// 함수 두 개 이상 Refactoring 
- [Refactoring] Refactoring Functions ({Function Name 1}, {Function Name 2}, ...)
// Class 단위 Naming Refactoring
- [Refactoring] Refactoring Naming of ({Class Name})

// 함수 하나 Fixed
- [Fixed] Fixed Function {Function Name} ({reason})
// 함수 두 개 이상 Fixed
- [Fixed] Fixed Functions ({Function Name 1}, {Function Name 2}, ...) ({reasons})
```
- 추가 
```
// 함수 하나 추가 
- [Added] Add Function {Function Name}
// 함수 두 개 이상 추가
- [Added] Add Functions ({Function Name 1}, {Function Name 2}, ...)
```
- 삭제 
```
// Component 삭제
- [Deleted] Delete Component ({reason})
// 함수 하나 삭제
- [Deleted] Delete Function ({reason})
// 함수 두 개 이상 삭제
- [Deleted] Delete Functions ({reason})
```

### Version Managing

**version rule**

```
v{Main Version (Sub Version 9 초과일 경우 or 큰 수정일 경우 +1)}.{Sub Version (3개 Feacture 수정될 경우 +1)}.{Minor Version (3개 미만 Feacture 수정될 경우 +1)}
```

### Version Log
